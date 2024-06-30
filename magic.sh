#!/bin/bash

# Start date
start_date="2024-01-08"
current_date=$start_date
last_date=$start_date

# Define tasks
tasks=(
    "echo 'Task 1: Writing to a file' >> ${current_date}.txt"
    "echo 'Task 2: Appending some random text' >> ${current_date}.txt"
    "echo 'Task 3: Logging the current date' > ${current_date}.log"
    "echo 'Task 4: Creating a backup file' > ${current_date}_backup.txt"
    "echo 'Task 5: Writing a random number' > ${current_date}_random.txt; echo \$RANDOM >> ${current_date}_random.txt"
)

# Custom shuffle function
shuffle() {
  local i tmp size max rand

  # Create an array of indices
  indices=($(seq 0 4))
  size=${#indices[*]}
  max=$(( 32768 / size * size ))

  for ((i=size-1; i>0; i--)); do
    while (( (rand=RANDOM) >= max )); do :; done
    rand=$(( rand % (i+1) ))
    tmp=${indices[i]}
    indices[i]=${indices[rand]}
    indices[rand]=$tmp
  done
}

# Loop for 60 days
for (( i=1; i<=60; i++ )); do
    # Determine if it's a commit day or not (60% chance of a commit)
    commit_day=$((RANDOM % 10))
    if [ $commit_day -lt 6 ]; then
        # Determine the number of commits for this day
        num_commits=1
        # On random days, make more than one commit
        if [ $((RANDOM % 5)) -eq 0 ]; then
            num_commits=$((RANDOM % 3 + 2))  # Make 2 or 3 commits
        fi

        # Loop to make multiple commits
        for (( c=1; c<=$num_commits; c++ )); do
            # Determine the number of tasks to run (between 1 and 5)
            num_tasks=$((RANDOM % 5 + 1))

            # Shuffle the task indices
            shuffle

            # Run the selected number of tasks
            for (( j=0; j<num_tasks; j++ )); do
                eval "${tasks[${indices[$j]}]}"
            done

            # Git operations
            git add .
            git commit -m "updates for $current_date"

            # Set the Git committer date and amend the commit
            git commit --amend --no-edit --date="$current_date 14:00:00"
        done
    fi

    # Move to the next day
    last_date=$current_date
    if date --version >/dev/null 2>&1; then
        current_date=$(date -I -d "$current_date + 1 day")
    else
        current_date=$(date -v +1d -I)
    fi
done
