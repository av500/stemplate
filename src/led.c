#include "main.h"
#include "led.h"

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#ifdef F4_WIFI

#define LED_GPIO_CLK_ENABLE __HAL_RCC_GPIOA_CLK_ENABLE

static uint16_t pins[LED_NUM]  = { 
	GPIO_PIN_0, 
	GPIO_PIN_0, 
	GPIO_PIN_0, 
	GPIO_PIN_0, 
};

static GPIO_TypeDef* ports[LED_NUM] = { 
	GPIOA, 
	GPIOA, 
	GPIOA, 
	GPIOA
};
#endif

#ifdef F4_DISCO

#define LED_GPIO_CLK_ENABLE __HAL_RCC_GPIOD_CLK_ENABLE

static uint16_t pins[LED_NUM]  = { 
	GPIO_PIN_12, 
	GPIO_PIN_13, 
	GPIO_PIN_14, 
	GPIO_PIN_15, 
};

static GPIO_TypeDef* ports[LED_NUM] = { 
	GPIOD, 
	GPIOD, 
	GPIOD, 
	GPIOD
};
#endif

#ifdef F3_DISCO

#define LED_GPIO_CLK_ENABLE __HAL_RCC_GPIOE_CLK_ENABLE

static uint16_t pins[LED_NUM]  = { 
	GPIO_PIN_8, 
	GPIO_PIN_9, 
	GPIO_PIN_10, 
	GPIO_PIN_11, 
};

static GPIO_TypeDef* ports[LED_NUM] = { 
	GPIOE, 
	GPIOE, 
	GPIOE, 
	GPIOE
};
#endif

#ifdef F1_TINY

#define LED_GPIO_CLK_ENABLE __HAL_RCC_GPIOA_CLK_ENABLE

static uint16_t pins[LED_NUM]  = { 
	GPIO_PIN_0, 
	GPIO_PIN_2, 
	GPIO_PIN_4, 
	GPIO_PIN_6, 
};

static GPIO_TypeDef* ports[LED_NUM] = { 
	GPIOA, 
	GPIOA, 
	GPIOA, 
	GPIOA
};
#endif

#ifdef F105_LITE

#define LED_GPIO_CLK_ENABLE __HAL_RCC_GPIOC_CLK_ENABLE

static uint16_t pins[LED_NUM]  = { 
	GPIO_PIN_2, 
	GPIO_PIN_2, 
	GPIO_PIN_2, 
	GPIO_PIN_2, 
};

static GPIO_TypeDef* ports[LED_NUM] = { 
	GPIOC, 
	GPIOC, 
	GPIOC, 
	GPIOC
};
#endif

void LED_on( unsigned int led )
{
	if( led >= LED_NUM ) {
		return;
	}
	HAL_GPIO_WritePin(ports[led], pins[led], GPIO_PIN_SET);
}

void LED_off( unsigned int led ) 
{
	if( led >= LED_NUM ) {
		return;
	}
	HAL_GPIO_WritePin(ports[led], pins[led], GPIO_PIN_RESET);
}

void LED_toggle( unsigned int led ) 
{
	if( led >= LED_NUM ) {
		return;
	}
	HAL_GPIO_TogglePin(ports[led], pins[led]);
}

void LED_init(void)
{
	GPIO_InitTypeDef GPIO_InitStruct;

	LED_GPIO_CLK_ENABLE();

	int i;
	for( i = 0; i < LED_NUM; i++ ) {
		GPIO_InitStruct.Pin   = pins[i];
		GPIO_InitStruct.Mode  = GPIO_MODE_OUTPUT_PP;
		GPIO_InitStruct.Pull  = GPIO_NOPULL;
		GPIO_InitStruct.Speed = GPIO_SPEED_FAST;

		HAL_GPIO_Init( ports[i], &GPIO_InitStruct );
		LED_off( i );
	}
}

