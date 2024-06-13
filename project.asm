  	.eqv BMP_FILE_SIZE 230522
  	.eqv BYTES_PER_ROW 960
  	.eqv x, a6
  	.eqv y, a5
  	.eqv cx, a4  
  	.eqv cy, a3  

    	.data

nline:  .asciz "\n"
coma:   .asciz ","

oerror: .asciz "Error opening the file :(\n"
terror: .asciz "Wrong file type :(\n"
  	.align 4

res:    .space 2
image:  .space BMP_FILE_SIZE

#fname:  .asciz "example.bmp"
fname:  .asciz "sourcee.bmp"
    	.text
#================================================  
init: 
  jal  check_type
  jal  read_bmp
  li s0, 24    	# image width    
  li s1, 24    	# image height
  li s2, 0x00000000
  li s6, -1    		# negative one used for calculations
  la t0, image      	# load the image address into t0
       
row_loop: 
  li x, 0      		# initialize row counter
       
column_loop:   
  mv a0, x    
  mv a1, y    
  jal get_pixel    

  beq a0, s2, find_corner   # if the pixel color is black, go to find_corner
  j next    
  
#================================================
find_corner:
  addi a0, x, -1  	# check left pixel
  mv a1, y
  jal get_pixel
  bne a0, s2, next
  
  addi a0, x, 1    	# check right pixel
  mv a1, y
  jal get_pixel
  beq a0, s2, next
  
  addi a1, y, -1  	# check bottom pixel
  mv a0, x
  jal get_pixel
  bne a0, s2, next
  
  addi a1, y, 1    	# check upper pixel
  mv a0, x
  jal get_pixel
  beq a0, s2, next
  
#================================================ 
# checking the pixel located diagonally from the top-right black pixel
top_right_corner:  
  jal restore
  
  addi cx, cx, 1
  addi cy, cy, 1
  
  mv a0, cx
  mv a1, cy
  jal get_pixel
  beq a0, s2, next
 
  jal restore 
  mv s8, y
  addi s8, s8, 1
 #================================================= 
check_ext_horz:
  addi cx, cx, -1
  mv a0, cx
  mv a1, cy
  jal get_pixel
  
  bne a0, s2, top_left_corner
  mv a0, cx
  mv a1, s8
  jal get_pixel
  
  beq a0, s2, next
  bne a0, s2, check_ext_horz
  
# checking the pixel located diagonally from the top-left black pixel
top_left_corner:
  mv a0, cx
  mv a1, s8
  jal get_pixel
  beq a0, s2, next
     
calc_length_h:
  sub s4, cx, x    # calculate length
  mul s4, s4, s6
    
  addi cx, cx, 1  # move back to black
   
  mv s8, cx    # going to the -1 left column to check the white
  addi s8, s8, -1
  li s9, 0     # initializing the width counter
  
check_width_h:
  addi cy, cy, -1
  
  mv a0, cx
  mv a1, cy
  jal get_pixel
  
  addi s9, s9, 1
  bne a0, s2, middle_left_corner
  
  mv a0, s8
  mv a1, cy
  jal get_pixel
  
  beq a0, s2, next
  b check_width_h

# checking the pixel located diagonally from the middle-left black pixel  
middle_left_corner:
  mv a0, s8
  mv a1, cy
  jal get_pixel
  beq a0, s2, next
  
find_inner_length:
  addi cy, cy, 1  	# move back to black
  
  mv s3, s9    		# save counter for further operations
    
  sub s11, s4, s9  	# internal length counter
  mv s7, s11   		# saving the s11 counter to the s7 registry for further use of s11
  
  mv s8, cy    		# going to the -1 bottom row to check the white
  addi s8, s8, -1 

  
check_inner_horz:
  addi cx, cx, 1
  
  mv a0, cx
  mv a1, cy
  jal get_pixel
  
  addi s7,s7, -1
  bne a0, s2, next
  beqz s7, move_to_vert_check
  
  mv a0, cx
  mv a1, s8
  jal get_pixel
  
  beq a0, s2, next
  bne a0, s2, check_inner_horz

move_to_vert_check:
  jal restore
  
  mv s8, x    		# going to the +1 right column to check the white
  addi s8, s8, 1
  
#===============================================
check_ext_vert:
  addi cy, cy, -1
  
  mv a0, x   
  mv a1, cy   
  jal get_pixel
  
  bne a0, s2, bottom_right_corner
  
  mv a0, s8
  mv a1, cy
  jal get_pixel
  
  beq a0, s2, next
  b check_ext_vert
  
# checking the pixel located diagonally from the bottom-right black pixel 
bottom_right_corner:
  mv a0, s8
  mv a1, cy
  jal get_pixel
  beq a0, s2, next
   
calc_length_v: 
  sub s5, cy, y    	# calculate length
  mul s5, s5, s6 
  
  addi cy, cy, 1  	# move back to black
  addi s9, s9, -1 
  
  mv s8, cy    		# going to the -1 bottom row to check the white
  addi s8, s8, -1
  
check_width_v:
  addi cx, cx, -1
  mv a0, cx
  mv a1, cy
  jal get_pixel
    
  beqz s9, bottom_left_corner
  addi s9, s9, -1
  bne a0, s2, next
  
  mv a0, cx
  mv a1, s8
  jal get_pixel  
  beq a0, s2, next
  
  b check_width_v  
 
# checking the pixel located diagonally from the bottom-left black pixel  
bottom_left_corner: 
  mv a0, cx
  mv a1, s8
  jal get_pixel  
  beq a0, s2, next
    
find_length_vert:
  mv s7, s11    	# internal length counter
  
  addi cx, cx, 1  	# back to black
  addi cy, cy, -1
  
  mv s8, cx    		# going to the -1 left column to check the white
  addi s8, s8, -1   
  
check_inner_vert:
  addi cy, cy, 1
  
  mv a0, cx   
  mv a1, cy   
  jal get_pixel
  
  addi s7, s7, -1
  bne a0, s2, next
  beqz s7, check_size
  
  mv a0, s8
  mv a1, cy
  jal get_pixel
  beq a0, s2, next
  b check_inner_vert  
  
check_size:
  bne s5, s4, next

#===============================================
preparation:
  sub s3, s4, s11
  jal restore
  addi s3, s3, -2    	# the "how many times" counter
  addi s4, s4, -2    	# lenth counter
  
find_new_corner:
  addi cx, cx, -1
  addi cy, cy, -1

  mv t5, cx
  mv s7, cy

  mv a0, cx
  mv a1, cy
  jal get_pixel
  bne a0, s2, next
  
  mv s8, s4    		# saving the length for further iterations
  
check_horz:
  addi t5, t5, -1
  mv a0, t5
  mv a1, cy
  jal get_pixel
  
  beqz s8, preparation_next
  addi s8, s8, -1
  bne a0, s2, next
  b check_horz

preparation_next:
  mv s8, s4
  
check_vert:
  addi s7, s7, -1
  mv a0, cx
  mv a1, s7
  jal get_pixel
  
  beqz s8, last_preparation
  addi s8, s8, -1
  bne a0, s2, next
  b check_vert

last_preparation:
  addi s4, s4, -1
  addi s3, s3, -1
  beqz s3, print
  b find_new_corner
#===============================================
print:  
  mv a0, x
  li a7, 1
  ecall
  
  la a0, coma
  li a7, 4
  ecall
  
  sub s10, s1, y  	#changing the у coordinates to the usual one
  addi s10, s10, -1
  
  mv a0, s10
  li a7, 1
  ecall
  
  la a0, nline
  li a7, 4
  ecall
  
next:
  addi x, x, 1    
  blt x, s0, column_loop   
        
  addi y, y, 1   
  blt y, s1, row_loop    
  b end
           
read_bmp:
  addi sp, sp, -4      # Reserve space on stack to save $s1
  sw s1, (sp)          # Save $s1 on stack (дескриптор)
  
#open file
  li a7, 1024
  la a0, fname      	#file name 
  li a1, 0        	#flags: 0-read file
  ecall
  mv s1, a0        	# save the file descriptor
  
#check for errors - if the file was opened
  li t1, -1
  beq a0, t1, exitWithOpenError      # exit if error has occured

#read file
  li a7, 63
  mv a0, s1
  la a1, image
  li a2, BMP_FILE_SIZE
  ecall

#close file
  li a7, 57
  mv a0, s1
  ecall
  
  lw s1, (sp)    	# restore (pop) s1
  addi sp, sp, 4  	# аdjust stack pointer to release saved space
  jr ra

get_pixel:
  bltz a0, set_new_value
  bltz a1, set_new_value
   
  li t1, 319
  bgt a0, t1, set_new_value
  
  li t1, 239
  bgt a1, t1, set_new_value
   
  #  a0 - x coordinate
  #  a1 - y coordinate
  
  # this part of code snippet loads the address of the pixel array from the BMP file header
  # and calculates its memory address using the image's starting address
  
  la t1, image    	# adress of file offset to pixel array
  addi t1,t1,10    	# adding an offset to get the offset to the pixel array
  lw t2, (t1)        	#file offset to pixel array in $t2
  la t1, image      	#adress of bitmap
  add t2, t1, t2      	#adress of pixel array in $t2
  
  #pixel address calculation
  li t4, BYTES_PER_ROW
  mul t1, a1, t4       	#t1= y*BYTES_PER_ROW (количество байтов, которое нужно пропустить, чтобы добраться до начала текущей строки)
  mv t3, a0    
  slli a0, a0, 1  	#  performs a left shift by 1 bit, to make room for the next color component in a 32-bit register.
  add t3, t3, a0      	#$t3= 3*x (тк. пиксель занимает 3 байта)
  add t1, t1, t3      	#$t1 = 3x + y*ByTES_PER_ROW (полученный пиксель)
  add t2, t2, t1    	#pixel address 
  
  #get color
  lbu a0,(t2)      # load B
  lbu t1,(t2)      # load G
  slli t1,t1,8     # shift the G component left by 8 bits (to align in a 32-bit register)
  or a0, a0, t1    # bitwise OR between the B and G components to combine them into a0
  lbu t1,(t2)      # load R
  slli t1,t1,16    # shift the R component left by 16 bits (to align in a 32-bit register)
  or a0, a0, t1    # bitwise OR between the B|G and R components to combine them into a0
          
  jr ra
 
set_new_value:
    li a0, 0x00FFFFFF
    jr ra
    
# assigning angle coordinates 
restore:
  mv cx, x  
  mv cy, y  
  jr ra
  
check_type:
  li s3, '.'
  la s6 fname
  lb t6, (s6)
  
check:
  beqz t6, exitWithTypeError
  
  addi s6, s6, 1
  lb t6, (s6)
  bne t6, s3, check
  
  li s3, 'b'
  addi s6, s6, 1
  lb t6, (s6)
  bne t6, s3, exitWithTypeError
  
  li s3, 'm'
  addi s6, s6, 1
  lb t6, (s6)
  bne t6, s3, exitWithTypeError
  
  li s3, 'p'
  addi s6, s6, 1
  lb t6, (s6)
  bne t6, s3, exitWithTypeError
  
  addi s6, s6, 1
  lb t6, (s6)
  bnez t6, exitWithTypeError
  
  jr ra
    
exitWithTypeError:
  la a0, terror
  li a7, 4
  ecall 
  j end
  
exitWithOpenError:
  la a0, oerror
  li a7, 4
  ecall
  
end:
  li a7, 10
  ecall
