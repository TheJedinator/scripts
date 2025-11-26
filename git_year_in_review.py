#!/usr/bin/env python3

import os
import subprocess
import sys
from collections import Counter, defaultdict
from datetime import UTC, date, datetime
from typing import TypedDict


class CommitData(TypedDict):
    hash: str
    date: datetime
    message: str
    files: list[str]
    additions: int
    deletions: int


class DayStats(TypedDict):
    count: int
    lines: int


def run_git_command(command: list[str], repo_path: str) -> str:
    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        cwd=repo_path,
        check=False,
    )
    return result.stdout


def get_user_name(repo_path: str) -> str:
    return run_git_command(["git", "config", "user.name"], repo_path).strip()


def get_user_email(repo_path: str) -> str:
    return run_git_command(["git", "config", "user.email"], repo_path).strip()


def get_commit_data(author: str, since_date: str, repo_path: str) -> list[CommitData]:
    # Calculate the end date (end of the year specified in since_date)
    year = int(since_date.split("-")[0])
    until_date = f"{year + 1}-01-01"

    log_output = run_git_command(
        [
            "git",
            "log",
            f"--author={author}",
            f"--since={since_date}",
            f"--until={until_date}",
            "--pretty=format:%H|%ai|%s",
            "--numstat",
        ],
        repo_path,
    )

    commits: list[CommitData] = []
    current_commit: CommitData | None = None

    for line in log_output.split("\n"):
        if not line.strip():
            continue

        if "|" in line and len(line.split("|")) == 3:
            if current_commit:
                commits.append(current_commit)

            hash_val, date_str, message = line.split("|", 2)
            current_commit = CommitData(
                hash=hash_val,
                date=datetime.fromisoformat(date_str.rsplit(" ", 1)[0]),
                message=message,
                files=[],
                additions=0,
                deletions=0,
            )
        elif current_commit and "\t" in line:
            parts = line.split("\t")
            if len(parts) == 3:
                added, deleted, filepath = parts
                try:
                    added_int = int(added) if added != "-" else 0
                    deleted_int = int(deleted) if deleted != "-" else 0
                    current_commit["additions"] += added_int
                    current_commit["deletions"] += deleted_int
                    current_commit["files"].append(filepath)
                except ValueError:
                    pass

    if current_commit:
        commits.append(current_commit)

    return commits


def analyze_top_directories(commits: list[CommitData], depth: int = 3) -> Counter[str]:
    dir_changes: Counter[str] = Counter()
    generic_dirs = {"src", "lib", "app", "core", "core_app", "pkg", "internal"}

    for commit in commits:
        dirs_in_commit: set[str] = set()
        for filepath in commit["files"]:
            if "/" not in filepath or filepath.startswith("."):
                continue

            parts = filepath.split("/")

            if len(parts) < 2:
                continue

            if parts[0] in generic_dirs and len(parts) >= depth + 1:
                dir_path = "/".join(parts[: depth + 1])
            elif len(parts) >= depth:
                dir_path = "/".join(parts[:depth])
            else:
                dir_path = "/".join(parts[:-1])

            dirs_in_commit.add(dir_path)

        for directory in dirs_in_commit:
            dir_changes[directory] += 1

    return dir_changes


def find_biggest_commit_day(commits: list[CommitData]) -> tuple[str, int, int]:
    daily_commits: defaultdict[date, DayStats] = defaultdict(
        lambda: DayStats(count=0, lines=0)
    )

    for commit in commits:
        day = commit["date"].date()
        daily_commits[day]["count"] += 1
        daily_commits[day]["lines"] += commit["additions"] + commit["deletions"]

    if not daily_commits:
        return ("", 0, 0)

    max_day = max(daily_commits.items(), key=lambda x: x[1]["count"])
    return (
        max_day[0].strftime("%B %d, %Y"),
        max_day[1]["count"],
        max_day[1]["lines"],
    )


def analyze_day_of_week(commits: list[CommitData]) -> Counter[str]:
    days: Counter[str] = Counter()
    for commit in commits:
        day_name = commit["date"].strftime("%A")
        days[day_name] += 1
    return days


def analyze_commit_hours(commits: list[CommitData]) -> Counter[int]:
    hours: Counter[int] = Counter()
    for commit in commits:
        hour = commit["date"].hour
        hours[hour] += 1
    return hours


def find_longest_streak(commits: list[CommitData]) -> tuple[int, str, str]:
    if not commits:
        return (0, "", "")

    commit_dates = sorted({c["date"].date() for c in commits})

    max_streak = 1
    current_streak = 1
    streak_start = commit_dates[0]
    max_streak_start = commit_dates[0]
    max_streak_end = commit_dates[0]

    for i in range(1, len(commit_dates)):
        if (commit_dates[i] - commit_dates[i - 1]).days == 1:
            current_streak += 1
        else:
            if current_streak > max_streak:
                max_streak = current_streak
                max_streak_start = streak_start
                max_streak_end = commit_dates[i - 1]
            current_streak = 1
            streak_start = commit_dates[i]

    if current_streak > max_streak:
        max_streak = current_streak
        max_streak_start = streak_start
        max_streak_end = commit_dates[-1]

    return (
        max_streak,
        max_streak_start.strftime("%b %d"),
        max_streak_end.strftime("%b %d"),
    )


def analyze_file_types(commits: list[CommitData]) -> Counter[str]:
    extensions: Counter[str] = Counter()
    for commit in commits:
        for filepath in commit["files"]:
            if "." in filepath:
                ext = filepath.rsplit(".", 1)[1]
                extensions[ext] += 1
    return extensions


def get_collaboration_stats(
    commits: list[CommitData], repo_path: str, user_name: str
) -> Counter[str]:
    collaborators: Counter[str] = Counter()

    for commit in commits:
        modified_files = set(commit["files"])

        for filepath in modified_files:
            if not filepath:
                continue

            blame_output = run_git_command(
                ["git", "log", "--pretty=format:%an", "--", filepath], repo_path
            )

            for author in blame_output.split("\n"):
                author = author.strip()
                if author and author != user_name:
                    collaborators[author] += 1

    return collaborators


def print_wrapped(user_name: str, commits: list[CommitData], since_date: str) -> None:
    year = since_date.split("-")[0]
    print("\n" + "=" * 60)
    print(f"🎉 {user_name}'s Git Wrapped {year} 🎉".center(60))
    print("=" * 60 + "\n")

    total_commits = len(commits)
    total_additions = sum(c["additions"] for c in commits)
    total_deletions = sum(c["deletions"] for c in commits)
    net_lines = total_additions - total_deletions

    print("📊 OVERALL STATS")
    print(f"   Total commits: {total_commits:,}")
    print(f"   Lines added: {total_additions:,}")
    print(f"   Lines removed: {total_deletions:,}")
    print(f"   Net lines: {net_lines:,}")
    print()

    top_dirs = analyze_top_directories(commits)
    if top_dirs:
        print("🏗️  YOUR TOP DIRECTORIES")
        for i, (directory, count) in enumerate(top_dirs.most_common(8), 1):
            print(f"   {i}. {directory}: {count} commits")
        print()

    biggest_day, commit_count, line_count = find_biggest_commit_day(commits)
    if biggest_day:
        print("🔥 BIGGEST COMMIT DAY")
        print(f"   {biggest_day}")
        print(f"   {commit_count} commits, {line_count:,} lines changed")
        print()

    days = analyze_day_of_week(commits)
    if days:
        most_productive_day = days.most_common(1)[0]
        print("📅 MOST PRODUCTIVE DAY")
        print(f"   {most_productive_day[0]} ({most_productive_day[1]} commits)")
        print()

    hours = analyze_commit_hours(commits)
    if hours:
        most_active_hour = hours.most_common(1)[0]
        hour_12 = most_active_hour[0] % 12
        if hour_12 == 0:
            hour_12 = 12
        am_pm = "AM" if most_active_hour[0] < 12 else "PM"
        print("⏰ MOST ACTIVE CODING HOUR")
        print(f"   {hour_12}:00 {am_pm} ({most_active_hour[1]} commits)")
        print()

    streak_days, start_date, end_date = find_longest_streak(commits)
    if streak_days > 1:
        print("🔥 LONGEST COMMIT STREAK")
        print(f"   {streak_days} consecutive days ({start_date} - {end_date})")
        print()

    file_types = analyze_file_types(commits)
    if file_types:
        print("📝 FAVORITE FILE TYPES")
        for i, (ext, count) in enumerate(file_types.most_common(3), 1):
            print(f"   {i}. .{ext} ({count} changes)")
        print()

    if commits:
        messages = [c["message"].lower() for c in commits]
        all_words = " ".join(messages).split()
        common_words = [
            w for w in all_words if len(w) > 3 and w not in ["feat", "from", "with"]
        ]
        word_counts = Counter(common_words)
        if word_counts:
            top_word = word_counts.most_common(1)[0]
            print("💬 YOUR MOST USED COMMIT WORD")
            print(f"   '{top_word[0]}' ({top_word[1]} times)")
            print()

    print("=" * 60)
    print(f"Thanks for shipping code in {since_date.split('-')[0]}! 🚀".center(60))
    print("=" * 60 + "\n")


def main() -> None:
    repo_path = os.getcwd()
    current_year = datetime.now(UTC).year
    since_date = f"{current_year}-01-01"

    args = sys.argv[1:]
    if args and os.path.isdir(args[0]):
        repo_path = os.path.abspath(args[0])
        args = args[1:]

    if args:
        since_date = args[0]

    user_name = get_user_name(repo_path)

    print(f"\n🔍 Analyzing commits by {user_name} since {since_date}...")
    print(f"📁 Repository: {repo_path}\n")

    commits = get_commit_data(user_name, since_date, repo_path)

    if not commits:
        print(f"No commits found for {user_name} since {since_date}")
        sys.exit(1)

    print_wrapped(user_name, commits, since_date)


if __name__ == "__main__":
    main()
