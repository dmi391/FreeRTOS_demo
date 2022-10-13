/*
 * FreeRTOS V202112.00
 * Copyright (C) 2020 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * https://www.FreeRTOS.org
 * https://github.com/FreeRTOS
 *
 */

#include <FreeRTOS.h>

#include <string.h>
#include <stdio.h>

#include "riscv-virt.h"
#include "htif.h"

extern char _LOG_START_ADDRESS;
char* currLogAddr = &_LOG_START_ADDRESS;

extern char _LOG_END_ADDRESS;
char* const endLogAddr = &_LOG_END_ADDRESS;

static const char endOfLogMem[] = "\nMemory log is over\n";

static int logIsOver = 0;

/*
* Return csr mcycle
*/
unsigned long xGetMcycle( void )
{
	unsigned long cycle;

	asm volatile ("csrr %[out], mcycle" :[out] "=r"(cycle)::);
	return cycle;
}

/*
* Write string to memory log
*/
void vLogWrite( char* str )
{
	if(!logIsOver)
	{
		size_t freeSpace = endLogAddr - currLogAddr;
		if(freeSpace > sizeof(endOfLogMem) + 20)
		{
			currLogAddr += sprintf(currLogAddr, str);
			currLogAddr += sprintf(currLogAddr, "\n");
		}
		else
		{
			currLogAddr += sprintf(currLogAddr, endOfLogMem);
			logIsOver = 1;
		}
	}
}

//Set use_htif = 1 with debugger for output to Spike terminal
volatile int use_htif = 0;

void vSendString( const char *s )
{
	portENTER_CRITICAL();

	if (use_htif) {
		while (*s) {
			htif_putc(*s);
			s++;
		}
		htif_putc('\n');
	}

	portEXIT_CRITICAL();
}

void handle_trap(void)
{
	while (1)
		;
}
