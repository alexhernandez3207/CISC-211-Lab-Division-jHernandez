/*** asmFunc.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

/* Tell the assembler that what follows is in data memory    */
.data
.align
/* Define the globals so that the C code can access them */
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Jesus Hernandez"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */
 
/* define a section for the lab variables at a fixed location.
 * This ensures the answers won't vary based on SW version or
 * other unrelated changes */
.section lab5data,data,address(0x20000800)

/* define and initialize global variables that C can access */

.global dividend,divisor,quotient,mod,we_have_a_problem
.type dividend,%gnu_unique_object
.type divisor,%gnu_unique_object
.type quotient,%gnu_unique_object
.type mod,%gnu_unique_object
.type we_have_a_problem,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmFunc gets called, you must set
 * them to 0 at the start of your code!
 */
dividend:          .word     0  
divisor:           .word     0  
quotient:          .word     0  
mod:               .word     0 
we_have_a_problem: .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmFunc
function description:
     output = asmFunc ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmFunc
.type asmFunc,%function
asmFunc:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    /* Save the inputs: r0 = dividend, r1 = divisor (both unsigned) */
    ldr r2,=dividend            /* r2 = address of the dividend variable */
    str r0,[r2]                 /* record the dividend input in memory */
    ldr r3,=divisor             /* r3 = address of the divisor variable */
    str r1,[r3]                 /* record the divisor input in memory */
    
    /* Clear all outputs, since they only get initialized once at program load */
    mov r4,#0                   /* r4 = running quotient; also a zero constant for clearing */
    ldr r5,=quotient            /* r5 = address of quotient (also returned to C in r0) */
    str r4,[r5]                 /* quotient = 0 in case we branch out on an error */
    ldr r6,=mod                 /* r6 = address of the mod (remainder) variable */
    str r4,[r6]                 /* mod = 0 in case we branch out on an error */
    ldr r7,=we_have_a_problem   /* r7 = address of the error flag */
    str r4,[r7]                 /* assume no error until the input check says otherwise */
    
    /* Input check: dividing by zero is an error, and a zero dividend is
     * also treated as an error by the lab spec */
    cmp r0,0                   /* is the dividend zero? */
    beq error                   /* yes: invalid input, report the error */
    cmp r1,0                   /* is the divisor zero? */
    beq error                   /* yes: cannot divide by zero, report the error */
    
    /* Division by repeated subtraction: subtract the divisor from the
     * remainder until what is left is smaller than the divisor. The number
     * of subtractions is the quotient; what remains is the modulus. */
    mov r8,r0                   /* r8 = remainder, starts as the full dividend */
div_loop:
    cmp r8,r1                   /* is remainder < divisor (unsigned compare)? */
    blo div_done                /* yes: no more whole divisors fit, stop */
    sub r8,r8,r1                /* take one divisor out of the remainder */
    add r4,r4,1                /* count that subtraction as one more in the quotient */
    b div_loop                  /* check whether another divisor still fits */
    
div_done:
    str r4,[r5]                 /* store the final count of subtractions as the quotient */
    str r8,[r6]                 /* store what is left over as dividend % divisor */
    mov r9,0                   /* r9 = 0, the "no error" value */
    str r9,[r7]                 /* confirm we_have_a_problem = 0 on the success path */
    mov r0,r5                   /* return the ADDRESS of quotient to the C code */
    b done                      /* skip the error handler */
    
error:
    mov r9,#1                   /* r9 = 1, the "error" value */
    str r9,[r7]                 /* set we_have_a_problem = 1 (quotient and mod stay 0) */
    mov r0,r5                   /* return the ADDRESS of quotient to the C code */
    b done                      /* leave the function */
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 /* this is a do-nothing line to deal with IDE mem display bug */

    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmFunc return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




