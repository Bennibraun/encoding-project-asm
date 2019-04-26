/*
	Benjamin Braun (braun4)
	CPSC 2310-002
	Assignment 4
	04/26/19
*/

			.file "encode.s"
			.text
			.align 2
			.global encode
			.type main, %function


/*
	function name: encode

	description: encodes a phrase using a key phrase
		and a shift cipher technique.

	input parameters:
		r0 - Address of input char array
		r1 - Address of output char array
		r2 - Address of key char array
		r3 - Encode/Decode toggle

	effect/output:
		stores encoded values in r1 (output char array)

	method/effect:
		Each char in the input and key arrays is given a value
		from 1-26 based on its position in the alphabet.
		Their values are added together to produce an encoded value.
		When the encoded value exceeds 26, 26 is subtracted from it.

	typical calling sequence:
		put a char array containing a phrase to encode in r0
		put a char array in which to store encoded phrase in r1
		put a char array containing a key phrase in r2
		put an integer with a value of 0 in r3 to select encoding mode
		call encode

	local register usage:
		r0 - address of phrase
		r1 - address of output array
		r2 - address of key array
		r3 - encode/decode toggle
		r4 - values of individual chars in phrase array
		r5 - values of individual chars in key array
		r6 - sums of phrase and key values
		r7 - used to read key values without losing original r2

*/

encode:
  push {lr}

  mov r7, #0x0

	cmp r3, #0
	bgt decode

	loop1:

		ldrb r4, [r0]					//load input string into r4
  	add r0, r0, #0x1			//increment r0 to access next element
		cmp r4, #0x0
    beq done							//if value in input is 0, phrase ended
    sub r4, r4, #0x60			// subtract 0x60 - convert to 1-26 ascii

	loopkey1:								//when key ends, start it over

		ldrb r5, [r2,r7] 			//load key string into r5
    add r7, r7, #0x1 			//increment r5 to get next char in key
    cmp r5, #0x0
    moveq r7, #0x0				//if key char==0, reset incrementation
		beq loopkey1					//reload key
    cmp r5, #0x20
    moveq r5, #0x0				//if key char is a space, it has no effect

		cmp r5, #0x0
    subgt r5, r5, #0x60		//if key char > 0, subtract 0x60 (96)
    add r6, r4, r5  			//add input char to key char
    cmp r6, #0x1A
    subgt r6, r6, #0x1A		//if sum > 26, subtract 0x1a (26)

    add r6, r6, #0x60			//return to actual ascii values
    strb r6, [r1]					//store encoded char in output array
		add r4, r4, #0x60			//return phrase char to ascii value
		cmp r4, #0x20					//check if phrase char is a space
		streqb r4, [r1]				//if space, override encoded value
    add r1, r1, #0x1			//increment to next char in output array

    b loop1

	b done



	/*
		function name: decode

		description: decodes an encoded phrase using a key
			and a shift cipher technique.

		input parameters:
			r0 - Address of encoded input char array
			r1 - Address of output char array
			r2 - Address of key char array
			r3 - Encode/Decode toggle

		effect/output:
			stores decoded values in r1 (output char array)

		method/effect:
			Each char in the input and key arrays is given a value
			from 1-26 based on its position in the alphabet.
			Their values are subtracted from each other to produce a
			decoded value.
			When the decoded value is less than 0, 26 is added to it.

		typical calling sequence:
			put a char array containing a phrase to decode in r0
			put a char array in which to store decoded phrase in r1
			put a char array containing the key phrase in r2
			put an integer with a value of 1 in r3 to select decoding mode
			call encode

		local register usage:
			r0 - address of encoded phrase
			r1 - address of output array
			r2 - address of key array
			r4 - values of individual chars in phrase array
			r5 - values of individual chars in key array
			r6 - differences of phrase and key values
			r7 - used to read key values without losing original r2

*/

decode:

	loop2:

		ldrb r4, [r0]					//load input string into r4
		add r0, r0, #0x1			//increment r0 to access next element
		cmp r4, #0x0
		beq done
		sub r4, r4, #0x60			//subtract 0x60 - convert to 1-26 ascii

	loopkey2:								//when key ends, start it over

		ldrb r5, [r2,r7] 			//load key char into r5
		add r7, r7, #0x1 			//increment r7 to get the next char
		cmp r5, #0x0
		moveq r7, #0x0				//if key char==0, reset incrementation
		beq loopkey2					//reload key
		cmp r5, #0x20
		moveq r5, #0x0				//if key char is a space, it has no effect

		cmp r5, #0x0
		subgt r5, r5, #0x60		//if key char > 0, subtract 0x60 (96)
		sub r6, r4, r5  			//find difference between input and key chars
		cmp r6, #0x1
		addlt r6, r6, #0x1A		//if difference < 1, add 0x1a (26)

		add r6, r6, #0x60			//return to actual ascii values
		strb r6, [r1]					//store decoded char in output array
		add r4, r4, #0x60			//return phrase char to ascii value
		cmp r4, #0x20					//check if phrase char is a space
		streqb r4, [r1]				//if space, override decoded value
		add r1, r1, #0x1			//increment to next char in output array

		b loop2


done:

	mov r4, #0x00000000
	str r4, [r1]						//clear up leftover data for next call

	pop {pc}
