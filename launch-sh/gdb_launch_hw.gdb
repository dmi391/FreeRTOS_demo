set height unlimited
set pagination off
target remote localhost:3333
monitor reset halt

load

#set debug remote 1


break main_blinky
continue


#monitor shutdown
#quit
#y
