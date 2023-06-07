; declare global constants
@.msg = internal constant [12 x i8] c"hello world\00"
@.loop_msg = internal constant [5 x i8] c"loop\00"

; declare puts function
declare i32 @puts(i8*)

define i32 @main() {
  ; get pointer to message
  %msg_ptr = getelementptr [12 x i8], [12 x i8]* @.msg, i8 0, i8 0

  ; print message
  call i32 @puts(i8* %msg_ptr)

  ; call loop function
  call void @loop(i32 5)

  ; return exit status
  ret i32 0
}

define void @loop(i32 %n) {
entry:
  ; go to body label
  br label %body

body:
  ; entry -> i = 0, latch -> i = i.next
  %i = phi i32 [ 0, %entry ], [ %i.next, %latch ]

  ; go to latch label
  br label %latch

latch:
  ; increment i without wrapping
  %i.next = add nsw i32 %i, 1

  ; check if i is less than n
  %cond = icmp slt i32 %i.next, %n

  ; get pointer to message
  %loop_msg_ptr = getelementptr [5 x i8], [5 x i8]* @.loop_msg, i8 0, i8 0

  ; print loop message
  call i32 @puts(i8* %loop_msg_ptr)

  ; i < n -> body, i >= n -> exit
  br i1 %cond, label %body, label %exit

exit:
  ; return void
  ret void
}
