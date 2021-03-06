#ifndef _MAIN_H_
#define _MAIN_H_

#ifdef F4_WIFI
#include "stm32f4xx_hal.h"
#include "stm32f4xx_it.h"
#endif

#ifdef F4_DISCO
#include "stm32f4xx_hal.h"
#include "stm32f4xx_it.h"
#endif

#ifdef F3_DISCO
#include "stm32f3xx_hal.h"
#include "stm32f3xx_it.h"
#define GPIO_SPEED_FAST GPIO_SPEED_FREQ_HIGH
#endif

#ifdef F1_TINY
#include "stm32f1xx_hal.h"
#include "stm32f1xx_it.h"

#define GPIO_SPEED_FAST GPIO_SPEED_HIGH
#endif

#ifdef F105_LITE
#include "stm32f1xx_hal.h"
#include "stm32f1xx_it.h"

#define GPIO_SPEED_FAST GPIO_SPEED_HIGH
#endif


void Error_Handler(void);

#endif 

