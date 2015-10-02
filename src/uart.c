#include "main.h"
#include "uart.h"

/* UART handler declaration */
static UART_HandleTypeDef huart;

static void __putc(uint8_t data)
{
    while(__HAL_UART_GET_FLAG(&huart, UART_FLAG_TXE) == RESET) {
    	// wait
    }
    huart.Instance->DR = data;
}

/*
int debug_getc( void )
{
	unsigned char c;
	int ret = HAL_UART_Receive(&huart, (uint8_t *)&c, 1, 0); 
	if(ret) { 
		return -1 * ret;
	}
	return c;
}
*/
/* Definition for USARTx clock resources */
#define USARTx                           USART2
#define USARTx_CLK_ENABLE()              __HAL_RCC_USART2_CLK_ENABLE();
#define USARTx_RX_GPIO_CLK_ENABLE()      __HAL_RCC_GPIOA_CLK_ENABLE()
#define USARTx_TX_GPIO_CLK_ENABLE()      __HAL_RCC_GPIOA_CLK_ENABLE()

#define USARTx_FORCE_RESET()             __HAL_RCC_USART2_FORCE_RESET()
#define USARTx_RELEASE_RESET()           __HAL_RCC_USART2_RELEASE_RESET()

/* Definition for USARTx Pins */
#define USARTx_TX_PIN                    GPIO_PIN_2
#define USARTx_TX_GPIO_PORT              GPIOA
#define USARTx_TX_AF                     GPIO_AF7_USART2
#define USARTx_RX_PIN                    GPIO_PIN_3
#define USARTx_RX_GPIO_PORT              GPIOA
#define USARTx_RX_AF                     GPIO_AF7_USART2

int UART_init( void )
{
	GPIO_InitTypeDef  GPIO_InitStruct;

	/* Enable GPIO TX/RX clock */
	USARTx_TX_GPIO_CLK_ENABLE();
	USARTx_RX_GPIO_CLK_ENABLE();

	/* UART TX GPIO pin configuration  */
	GPIO_InitStruct.Pin	  = USARTx_TX_PIN;
	GPIO_InitStruct.Mode	  = GPIO_MODE_AF_PP;
	GPIO_InitStruct.Pull	  = GPIO_NOPULL;
	GPIO_InitStruct.Speed	  = GPIO_SPEED_FAST;
	GPIO_InitStruct.Alternate = USARTx_TX_AF;

	HAL_GPIO_Init(USARTx_TX_GPIO_PORT, &GPIO_InitStruct);

	/* UART RX GPIO pin configuration  */
	GPIO_InitStruct.Pin       = USARTx_RX_PIN;
	GPIO_InitStruct.Alternate = USARTx_RX_AF;

	HAL_GPIO_Init(USARTx_RX_GPIO_PORT, &GPIO_InitStruct);

	/* Enable USARTx clock */
	USARTx_CLK_ENABLE(); 

	/*##-1- Configure the UART peripheral ######################################*/
	/* Put the USART peripheral in the Asynchronous mode (UART Mode) */
	/* UART1 configured as follow:
	    - Word Length = 8 Bits
	    - Stop Bit = One Stop bit
	    - Parity = ODD parity
	    - BaudRate = 9600 baud
	    - Hardware flow control disabled (RTS and CTS signals) */
	huart.Instance	        = USARTx;
	huart.Init.BaudRate     = DEBUG_BAUDRATE;
	huart.Init.WordLength   = UART_WORDLENGTH_8B;
	huart.Init.StopBits     = UART_STOPBITS_1;
	huart.Init.Parity       = UART_PARITY_NONE;
	huart.Init.HwFlowCtl    = UART_HWCONTROL_NONE;
	huart.Init.Mode	        = UART_MODE_TX_RX;
	huart.Init.OverSampling = UART_OVERSAMPLING_16;
	  
	int ret;
	if((ret = HAL_UART_Init(&huart)) != HAL_OK)
	{
		return ret;
	}

	return HAL_OK;
}

#ifdef __GNUC__
int __io_putchar(int ch) 
{
	if (ch == '\n') 
		__putc('\r');
	__putc(ch);
	return ch;
}
#else
int fputc(int ch, FILE *f) 
{
	__putc(ch);
	return ch;
}
#endif
