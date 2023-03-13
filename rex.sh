#!/bin/bash

# Function to display the dinosaur
function show_dinosaur {
  echo -ne "\033[2K"   # clear the current line
  echo -ne "\r"        # move cursor to the beginning of the line
  echo -ne "$1"        # display the dinosaur
}

# Run terraform apply command in background
terraform apply &

# Store the PID of terraform apply command
PID=$!

# Characters for the dinosaur
DINO="/-\|"

# Start the progress bar
while kill -0 $PID 2> /dev/null; do
  for i in $(seq 0 3); do
    show_dinosaur "$DINO$DINO${DINO:$i:1} Simulating Disaster ..."
    sleep 0.2
  done
done

# Display the final output after terraform apply command completes
show_dinosaur "🦕 Terraform apply completed"
echo ""


# #!/bin/bash

# # Define the animation frames for the dinosaur.
# frames=("⢀⠀" "⡀⠀" "⠄⠀" "⢂⠀" "⡂⠀" "⠅⠀" "⢃⠀" "⡃⠀" "⠍⠀" "⢋⠀" "⡋⠀" "⠍⠁" "⢋⠁" "⡋⠁" "⠍⠉" "⢋⠉" "⡋⠉" "⠍⠛" "⢋⠛" "⡋⠛")

# # Define a function to print the progress bar with the dinosaur animation.
# function progress_bar() {
#   local width=40
#   local percent=$(echo "scale=2; $1 / $2 * 100" | bc)
#   local filled=$(echo "$percent / 2" | bc)
#   local empty=$(echo "$width - $filled" | bc)
#   printf "\r["
#   printf "%0.s=" $(seq 1 $filled)
#   printf "%0.s " $(seq 1 $empty)
#   printf "] %d%% ${frames[$3]}" $percent
# }

# # Run the Terraform apply command in the background.
# terraform apply &

# # Store the process ID of the Terraform command.
# terraform_pid=$!

# # Continuously update the progress bar until the Terraform command completes.
# while kill -0 $terraform_pid 2>/dev/null; do
#   progress_bar $(terraform state list | wc -l) $(terraform state list | wc -l) $((i++ % ${#frames[@]}))
#   sleep 1
# done

# # Once the Terraform command completes, print the final progress bar and exit.
# progress_bar $(terraform state list | wc -l) $(terraform state list | wc -l) $((i++ % ${#frames[@]}))
# printf "\n"



# # T-Rex ASCII art
# t_rex="        ___
#                .-^  |  ^-.
#               /     |     \
#              /      |      \
#             /       |       \
#            /        |        \
#           /         |         \
#          /          |          \
#         /           |           \
#        /            |            \
#       /             |             \
#      /              |              \
#     /               |               \
#    /                |                \
#   /                 |                 \
#  /                  |                  \
# /                   |                   \
# \                                       |
#  \                                      |
#   \                                     |
#    \                                    |
#     \                                   |
#      \                                  |
#       \                                 |
#        \                                |
#         \                               |
#          \                              |
#           \                             |
#            \                            |
#             \                           |
#              \                          |
#               \                         |
#                '-._                    |
#                    `--.                |
#                        `--..__         |
#                                `^-._    |
#                                     `--.|"

# # loop from 1 to 100
# for i in {1..100}; do
#     # calculate progress bar
#     progress=$(echo "scale=2; $i / 100" | bc)
#     width=$(tput cols)
#     bar_width=$(echo "scale=0; $width * $progress" | bc)
#     empty_width=$(echo "scale=0; $width * (1 - $progress)" | bc)
#     bar=$(printf "%0.s=" $(seq 1 $bar_width))
#     empty=$(printf "%0.s " $(seq 1 $empty_width))

#     # display progress bar and T-Rex
#     printf "\r[%s%s] %d%%\n%s" "$bar" "$empty" "$i" "$t_rex"
#     sleep 0.1
# done