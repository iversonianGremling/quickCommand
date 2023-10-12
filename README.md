<p align="center"> QUICK COMMAND </p>

<p align="center">
  <img src="https://github.com/Vdevelasco/quickCommand/assets/24989959/fba5b870-b5cb-43b3-9e94-f1c04183fd4b" />
  
</p>



Optional (recommended) dependencies:

- dmenu + zsh or fzf

Quick command is a series of small scripts (and an optional zsh widget) designed to improve efficiency when dealing with repetitive tasks, it can also work from the terminal via fzf, so basically

It provides a workflow that allows you to add recently used commands from history to a stack that can later be used with a few keystrokes

Quick command consists of the following parts:
- qc: the core script, here's the usage:

  Usage: /usr/local/bin/qc [-ihrlcmsexd] [-a command] [-f file] [-b size]

  Run qc -i first to set up files needed

   -a: adds a new command to the bottom of the stack

   -i: (init) has to be run one time before using any other commands

   -h: (help) outputs this message

   -r:  removes a specific command from the list

   -l: lists all stored commands

   -c: creates a simple script with all the stored commands

   -m: modifies the command in a specific slot

   -s: switches two commands

   -b: changes the size of the stack

   -e: loads the commands in a file that can be used as a script

   -x: lists avaliable command lists

   -d: lists the directories used by qc
- dmenu_instant: a small edition on dmenu that outputs the first match immediately after pressing one character, needed for dm-qc to work
- dm-qc/fzf-qc: shows the commands currently loaded in the stack, each one has an index asigned, when the index number is pressed the command is executed, it's recommended to map this to a keybinding or an alias to maximize speed
- dm-qcl/fzf-qcl: lists all the saved stacks and loads the one selected
- zsh_history_widget: a widget made by (author couldn't be found) modified for using with qc, it shows the history of the current terminal in a dmenu and adds the selected command to the stack

TODO:

  -Currently only tested with zsh, an analogous to zsh_history_widget for bash and other shells is needed
      
  -Add a makefile or similar to put all the programs in a proper directory
    
  -Improve code cleanness in qc 
    
  -Provide better documentation
     
  -Add a video showing its usage for better clarity

  -Load commands whenever used in an specific folder (some kind of session saving) 
