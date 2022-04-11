.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_svc
.global asm_sum
.global asm_zeros
.global asm_productoEscalar32

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_zeros(uint32_t * vector, uint32_t longitud)
@
@ Parametros recibidos:
@   r0: firstOperand - puntero al vector de uint32_t
@   r1: secondOperand - longitud del vector
@
@ Valor de retorno:
@   void
@
.thumb_func
    asm_zeros:
        mov r2, 0
   .asm_zeros_loop:
        str r2,[r0], 4
        subs r1, 1	// Cuando llega a cero cambia el flag a 1
		bne .asm_zeros_loop
        bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar32(uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar);
@
@ Parametros recibidos:
@   r0: Primer operando - puntero al vector de uint32_t
@   r1: Segundo operando - puntero al vector de salida del uint32_t
@   r2: Tercer operando - longitud de los vectores
@	r3: Cuarto operando - Escalar con el que voy a efectuar la multiplicacion
@ Valor de retorno:
@   void
@
.thumb_func
    asm_productoEscalar32:
   .asm_prodEscalar_loop:
        and r1, [r0], r3
        add r0, 4
        add r1, 4
        subs r2, 1	// Cuando llega a cero cambia el flag a 1
		bne .asm_prodEscalar_loop
        bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: Primer operando - puntero al vector de uint16_t
@   r1: Segundo operando - puntero al vector de salida del uint16_t
@   r2: Tercer operando - longitud de los vectores
@	r3: Cuarto operando - Escalar con el que voy a efectuar la multiplicacion
@ Valor de retorno:
@   void
@
.thumb_func
    asm_productoEscalar16:
   .asm_prodEscalar_loop:
        and r1, [r0], r3
        add r0, 2
        add r1, 2
        subs r2, 1	// Cuando llega a cero cambia el flag a 1
		bne .asm_prodEscalar_loop
        bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: Primer operando - puntero al vector de uint16_t
@   r1: Segundo operando - puntero al vector de salida del uint16_t
@   r2: Tercer operando - longitud de los vectores
@	r3: Cuarto operando - Escalar con el que voy a efectuar la multiplicacion
@ Valor de retorno:
@   void

@	usat r1,12,r0

.thumb_func
    asm_productoEscalar12:
   .asm_prodEscalar_loop:
        and r1, [r0], r3
        usat r1, 12, r1	// saturo a 12 bit sin signo
        add r0, 2
        add r1, 2
        subs r2, 1	// Cuando llega a cero cambia el flag a 1
		bne .asm_prodEscalar_loop
        bx lr
