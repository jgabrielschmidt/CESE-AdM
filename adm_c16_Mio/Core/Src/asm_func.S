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
.global pack32to16
.global asm_max
.global asm_downsampleM
.global asm_invertir

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

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N);
@
@ Parametros recibidos:
@   r0: Primer operando - puntero al vector de entrada de int32_t
@   r1: Segundo operando - puntero al vector de salida de int32_t
@ 	R2: Tercer operando - longitud de los vectores uint32_t
@ 	R3: Cuarto operando - N muestra a quitar uint32_t
@
@ Valor de retorno:
@   void
@
@ R4: Utilizado para comparar con la muestra N a sacar (Contador hasta N)
@ R5: Utilizado para guardar en el vectorOut el item del vectorIn
@ R6: Utilizado para contar la cantidad de items del vector (Contador hasta R2)
@

.thumb_func
    asm_downsampleM:

		/* Guardo registros en la pila */
		PUSH {R4 - R6}
		/* Inicializo el registro R4 */
		MOV R4, #0
		MOV R6, #0
		/* Comparo R4 con el numero de item a sacar */
	.asm_downsampleM_loop1:
		CMP R4, R3
		BEQ .asm_downsampleM_Nocopiar
		/* Si no toca sacar el item, lo guardo en vectorOut */
		LDR R5, [R0], #4
		STR R5,[R1], #4
		ADD R4, #1
		B .asm_downsampleM_contador
		/* Si toca sacar el item, avanzo en el vectorIn y no lo copio al vectorOut, reseteo R4 para contar nuevamente hasta N */
	.asm_downsampleM_Nocopiar:
		LDR R5, [R0], #4
		MOV R4, #0
		/* avanzo en el vectorIn - Su contador */
	.asm_downsampleM_contador:
		ADD R6, #1
		CMP R2, R6
		BNE .asm_downsampleM_loop1

		POP {R4 - R6}

 		bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_invertir (uint16_t * vector, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: Primer operando - puntero al vector de entrada de int32_t
@   r1: Segundo operando - longitud del vector de entrada
@
@ Valor de retorno:
@   void

.thumb_func
    asm_invertir:

		/* Guardo registros en la pila */
		PUSH {R4 - R5}
		/* Calculo la posicion del ultimo elemento del vector */
		MOV R4, R1
		SUBS R4, #1 // De N elementos el final sera N - 1
		MOV R3,#2
		MUL R4, R3  // Al ser uint16_t multiplico x 2
		/* Apunto el R2 al final del vector */
		MOV R2, R0
		ADD R2, R4
		/* Le resto 2 a la cantidad de combinaciones a iterar
		 * Para 3 elementos: 1 iteracion
		 * Para 4 elementos: 2 iteraciones
		 * Para N elementos: N - 2 iteraciones
		 */
		SUBS R1, #2

	.asm_invertir_loop1:
		LDRH R4, [R2]	// Copio el valor del extremo derecho del vector
		LDRH R5, [R0]	// Copio el valor del extremo izquierdo del vector
		/* Intercambio valores entre las puntas */
		STRH R5, [R2], -2
		STRH R4, [R0], 2

		SUBS R1, #1	// Cuando llega a cero cambia el flag a 1
		BNE .asm_invertir_loop1

		POP {R4 - R5}

 		bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: Primer operando - puntero al vector de entrada de int32_t
@   r1: Segundo operando - puntero al vector de salida de int16_t
@   r2: Tercer operando - longitud del vector de entrada
@ Valor de retorno:
@   void

.thumb_func
    pack32to16:

		LDR R3, [R0], #4	// Cargo el valor de lo que apunta R0 en R3
		LSR R3, R3, #16		// Lo desplazo 16 bit a la derecha
		STR R3, [R1], #4	// Cargo el resultado en el vactor de salida

 		bx lr

