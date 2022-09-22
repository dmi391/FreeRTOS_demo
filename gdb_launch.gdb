set height unlimited
set pagination off
target remote localhost:3333
monitor reset halt

load

#set debug remote 1


break _start
break main


#tui enable
#focus cmd


continue
#frame


#monitor shutdown
#quit
#y
