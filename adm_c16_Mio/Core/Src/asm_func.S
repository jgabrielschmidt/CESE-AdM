.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_svc
.global asm_sum
.global asm_zeros
.global asm_productoEscalar32
.global asm_productoEscalar16
.global asm_productoEscalar12
.global asm_filtroVentana10

.global asm_max
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
   .asm_prodEscalar_loop32:
   		ldr r4, [r0], 4
        mul r4, r4, r3
        str r4,[r1], 4
        subs r2, 1	// Cuando llega a cero cambia el flag a 1
		bne .asm_prodEscalar_loop32
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
   .asm_prodEscalar_loop16:
   		ldr r4, [r0], 2
        mul r4, r4, r3
        str r4,[r1], 2
        subs r2, 1	// Cuando llega a cero cambia el flag a 1
		bne .asm_prodEscalar_loop16
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

.thumb_func
    asm_productoEscalar12:
    	push {r4,r5}
    	mov r5, 0x0FFF
   .asm_prodEscalar12_loop:
  		ldr r4, [r0], 2
        mul r4, r4, r3
        and r4, r4, r5
        str r4,[r1], 2
        subs r2, 1	// Cuando llega a cero cambia el flag a 1
		bne .asm_prodEscalar12_loop
		pop {r4,r5}
        bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn);
@
@ Parametros recibidos:
@   r0: Primer operando - puntero al vector de entrada de uint16_t
@   r1: Segundo operando - puntero al vector de salida de uint16_t
@   r2: Tercer operando - longitud de los vectores
@ Valor de retorno:
@   void
@
@ R4: Acumulador
@ R5: Variable de control para sumar 10 elementos
@ R6: Cuenta las ventanas promedidadas
@
/*
	Codigo equivalente en C

	for(uint32_t i = 0; (i + 10) <= longitudVectorIn; i++)
	{
		for(uint8_t j = i; j < (10 + i); j++)
		{
			vectorOut[i] += vectorIn[j];
		}
		vectorOut[i] /= 10;
	}



	*/
.thumb_func
    asm_filtroVentana10:

		/* Primero me fijo que la longitud sea mayor que 9*/
		push {R4}
		MOV R4, #9
		CMP	R2, R4
		/* Si no lo es termina la funcion */
		BLS .asm_fin

		push {R5-R6}
		/* Inicializo los registros R6 R4 */
		MOV R6, #0
		MOV R4, #0
	.asm_filtroVentana10_for1:
		MOV R5, #10
	.asm_filtroVentana10_for2:
		LDRH R3, [R0], #2
		ADD R4, R3
        SUBS R5, #1	// Cuando llega a cero cambia el flag a 1
		BNE .asm_filtroVentana10_for2

		ADD R6, #1    // sume un ciclo de 10 items mas
		MOV R5, #10   // Restaruro el valor de 10 para dividir
		UDIV R4,R4,R5 // Hago la division
		STRH R4,[R1], #2 // guardo el resultado en el vector de salida

		/* Me fijo si puedo correr la ventana una unidad hacia la izquierda */
		ADD R5, R6
		CMP	R5, R2  		// Comparo la longitud con 10 + 1 elemento
		BLS .asm_volver_r0  // Si tengo un elemento mas itero nuevamente, pero primero vuelvo el puntero R0 a el item 2
		B .asm_fin			// Si no tengo otro, termino la funcion

	/* Vuelvo el puntero R0 a R0[1], asi sumo a partir del R0[1] hasta  R0[11], y asi hasta la longitud del vector */
	.asm_volver_r0:
		SUB R0, #20
		B .asm_filtroVentana10_for1

	.asm_fin:
		pop {R4-R6}

        bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ int32_t asm_max(int32_t * vectorIn, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: Primer operando - puntero al vector de entrada de uint16_t
@   r1: Segundo operando - puntero al vector de salida de uint16_t
@ Valor de retorno:
@   void
@
@ R2: Guardo el maximo
@ R3: Registro que recorre el vectro buscando un nuevo maximo
@ R4: Guarda la posicion del maximo en el vector

.thumb_func
    asm_max:

		/* Guardo registro R4 en la pila */
		push {R4}
		/* Inicializo el registro R4 */
		MOV R4, #0
		LDR R2, [R0], #4
		SUBS R1, #1
	.asm_max_loop1:
		LDR R3, [R0], #4
		CMP R3, R2
		BHI .asm_max_actualizar
		B .asm_max_avanzar

	/* Copio la posicion y el maximo */
	.asm_max_actualizar:
		ADD R4, #1
		MOV R2, R3

	/* descuento una posicion en el vector */
	.asm_max_avanzar:
		SUBS R1, #1	// Cuando llega a cero cambia el flag a 1
		BNE .asm_max_loop1

	/* Copio la posicion del maximo al registro de salida */
		MOV R0,R4

		pop {R4}

        bx lr
