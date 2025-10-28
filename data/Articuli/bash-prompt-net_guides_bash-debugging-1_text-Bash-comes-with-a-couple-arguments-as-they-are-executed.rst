Bash Prompt GuideswhoamiEmploy Me (BUTTON)

* Guides * whoami * Employ Me

Debugging Bash Scripts - Part 1 - Verbose Output

Here is the list of all the Bash debugging posts: * Verbose Output * Using exit command * Using echo command * Using ShellCheck * Jummping Forward

When you run a Bash script it will only usually print the output of the commands that you execute. This is fine until you need to figure out why it isn’t doing what you want.

Bash comes with a couple of options that will show you exactly what is being run and also print out the lines of the script in the order of the execution output, including comments.

These options are: * -v Print shell input lines as they are read. * -x Print commands and their arguments as they are executed.

These options can either be set at the beginning of the script and will get executed every time you run the script e.g.: #!/bin/bash set -vx

Or you can invoke them when you run the script as follows: $ bash -vx script.sh

What they do will be easier to see with an example. The following script (yes I know the echo is redundant, it’s just something to see working): $ cat script.sh #!/bin/bash

# Set a variable for the directory we want to search in dir="files/"

# Find all the files in the files directory files=$(find "$dir" -type f)

# Echo the file list echo "$files"

When this script runs it prints out all the names of all the files in the “files” directory: $ ./script.sh files/1.txt files/2.txt files/3.txt files/4.txt files/5.txt files/6.txt files/7.txt files/8.txt files/9.txt files/10.txt

If the script is invoked with the -v command it prints every line of the bash script and also prints their output: $ bash -v script.sh #!/bin/bash

# Set a variable for the directory we want to search in dir="files/"

# Find all the files in the files directory files=$(find "$dir" -type f)

# Echo the file list echo "$files" files/1.txt files/2.txt files/3.txt files/4.txt files/5.txt files/6.txt files/7.txt files/8.txt files/9.txt files/10.txt

The -x option will print the commands as they are executed. It will also, substitute any variables with the values you set: $ bash -x script.sh + dir=files/ ++ find files/ -type f + files='files/1.txt files/2.txt files/3.txt files/4.txt files/5.txt files/6.txt files/7.txt files/8.txt files/9.txt files/10.txt' + echo 'files/1.txt files/2.txt files/3.txt files/4.txt files/5.txt files/6.txt files/7.txt files/8.txt files/9.txt files/10.txt' files/1.txt files/2.txt files/3.txt files/4.txt files/5.txt files/6.txt files/7.txt files/8.txt files/9.txt files/10.txt

Using both together lets you see each line as it appears in the script and how it is executed: $ bash -vx script.sh #!/bin/bash

# Set a variable for the directory we want to search in dir="files/" + dir=files/

# Find all the files in the files directory files=$(find "$dir" -type f) ++ find files/ -type f + files='files/1.txt files/2.txt files/3.txt files/4.txt files/5.txt files/6.txt files/7.txt files/8.txt files/9.txt files/10.txt'

# Echo the file list echo "$files" + echo 'files/1.txt files/2.txt files/3.txt files/4.txt files/5.txt files/6.txt files/7.txt files/8.txt files/9.txt files/10.txt' files/1.txt files/2.txt files/3.txt files/4.txt files/5.txt files/6.txt files/7.txt files/8.txt files/9.txt files/10.txt

Using -vx is very helpful to see exactly what you have written, and how Bash is executing it.

Finally, you may only want to get the debug output for a specific part of a script. You can do this by setting and then unsetting the -vx switches.

First put set -vx before the problem part and unsetting it with +vx after e.g.: #!/bin/bash

set -vx # Set a variable for the directory we want to search in dir="files/" set +vx

# Find all the files in the files directory files=$(find "$dir" -type f)

#Echo the file list echo "$files"

This now prints the verbose output for the part of the script you are having the problem with e.g.: $ ./script.sh # Set a variable for the directory we want to search in dir="files/" + dir=files/ set +vx + set +vx files/1.txt files/2.txt files/3.txt files/4.txt files/5.txt files/6.txt files/7.txt files/8.txt files/9.txt files/10.txt

© 2025 Elliot Cooper · Copyright · Made with Hugo · Theme Hermit-V2Learn Linux With Me

References

1. https://bash-prompt.net/ 2. https://bash-prompt.net/guides/ 3. https://bash-prompt.net/about/ 4. https://elliotcooper.com/ 5. https://bash-prompt.net/guides/ 6. https://bash-prompt.net/about/ 7. https://elliotcooper.com/ 8. https://bash-prompt.net/guides/bash-debugging-1 9. https://bash-prompt.net/guides/bash-debugging-2 10. https://bash-prompt.net/guides/bash-debugging-3 11. https://bash-prompt.net/guides/bash-debugging-4 12. https://bash-prompt.net/guides/bash-debugging-5 13. https://elliotcooper.com/ 14. https://gohugo.io/ 15. https://github.com/1bl4z3r/hermit-V2 16. https://learn.elliotcooper.com/

