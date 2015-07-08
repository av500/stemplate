#include "main.h"
#include "led.h"

static TIM_HandleTypeDef timer4_handle;

static int      timer4_clock   = 1000000;
static uint16_t timer4_CCR1Val = 1000;

#ifdef F4_DISCO
static void SystemClock_Config( void )
{
	RCC_ClkInitTypeDef RCC_ClkInitStruct;
	RCC_OscInitTypeDef RCC_OscInitStruct;

	/* Enable Power Control clock */
	__HAL_RCC_PWR_CLK_ENABLE(  );

	/* The voltage scaling allows optimizing the power consumption when the device is 
	   clocked below the maximum system frequency, to update the voltage scaling value 
	   regarding system frequency refer to product datasheet.  */
	__HAL_PWR_VOLTAGESCALING_CONFIG( PWR_REGULATOR_VOLTAGE_SCALE1 );

	// Enable HSE Oscillator and activate PLL with HSE as source
	// 
	// clock is 168MHz
	//
	RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
	RCC_OscInitStruct.HSEState       = RCC_HSE_ON;		// 8 MHz
	RCC_OscInitStruct.PLL.PLLState   = RCC_PLL_ON;
	RCC_OscInitStruct.PLL.PLLSource  = RCC_PLLSOURCE_HSE;
	RCC_OscInitStruct.PLL.PLLM       = 8;			// 8 MHz * 336 / 8 = 336 MHz
	RCC_OscInitStruct.PLL.PLLN       = 336;
	RCC_OscInitStruct.PLL.PLLP       = RCC_PLLP_DIV2;	// 336 MHz / 2 = 168 MHZ
	RCC_OscInitStruct.PLL.PLLQ       = 7;			// 336 MHz / 7 =  48 MHz

	if ( HAL_RCC_OscConfig( &RCC_OscInitStruct ) != HAL_OK ) {
		Error_Handler();
	}

	/* Select PLL as system clock source and configure the HCLK, PCLK1 and PCLK2 
	   clocks dividers */
	RCC_ClkInitStruct.ClockType      = ( RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2 );
	RCC_ClkInitStruct.SYSCLKSource   = RCC_SYSCLKSOURCE_PLLCLK;
	RCC_ClkInitStruct.AHBCLKDivider  = RCC_SYSCLK_DIV1;	// 168 MHz / 1 = 168 MHZ (168 MHz max)
	RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;	// 168 MHZ / 2 =  84 MHz ( 84 MHZ max)
	RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;	// 168 MHz / 4 =  42 MHz ( 42 MHz max)
	if ( HAL_RCC_ClockConfig( &RCC_ClkInitStruct, FLASH_LATENCY_5 ) != HAL_OK ) {
		Error_Handler();
	}

	/* STM32F405x/407x/415x/417x Revision Z devices: prefetch is supported  */
	if ( HAL_GetREVID() == 0x1001 ) {
		__HAL_FLASH_PREFETCH_BUFFER_ENABLE();
	}
}
#endif
#if defined( F1_TINY ) || defined( F105_LITE )
/**
  * @brief  System Clock Configuration
  *         The system Clock is configured as follow : 
  *            System Clock source            = PLL (HSE)
  *            SYSCLK(Hz)                     = 72000000
  *            HCLK(Hz)                       = 72000000
  *            AHB Prescaler                  = 1
  *            APB1 Prescaler                 = 2
  *            APB2 Prescaler                 = 1
  *            HSE Frequency(Hz)              = 8000000
  *            HSE PREDIV1                    = 1
  *            PLLMUL                         = 9
  *            Flash Latency(WS)              = 2
  * @param  None
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_ClkInitTypeDef clkinitstruct = {0};
  RCC_OscInitTypeDef oscinitstruct = {0};
  
  /* Enable HSE Oscillator and activate PLL with HSE as source */
  oscinitstruct.OscillatorType  = RCC_OSCILLATORTYPE_HSE;
  oscinitstruct.HSEState        = RCC_HSE_ON;
  oscinitstruct.HSEPredivValue  = RCC_HSE_PREDIV_DIV1;
  oscinitstruct.PLL.PLLState    = RCC_PLL_ON;
  oscinitstruct.PLL.PLLSource   = RCC_PLLSOURCE_HSE;
  oscinitstruct.PLL.PLLMUL      = RCC_PLL_MUL9;
  if (HAL_RCC_OscConfig(&oscinitstruct)!= HAL_OK)
  {
    /* Initialization Error */
    while(1);
  }

  /* Select PLL as system clock source and configure the HCLK, PCLK1 and PCLK2 
     clocks dividers */
  clkinitstruct.ClockType = (RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2);
  clkinitstruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  clkinitstruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  clkinitstruct.APB2CLKDivider = RCC_HCLK_DIV1;
  clkinitstruct.APB1CLKDivider = RCC_HCLK_DIV2;  
  if (HAL_RCC_ClockConfig(&clkinitstruct, FLASH_LATENCY_2)!= HAL_OK)
  {
    /* Initialization Error */
    while(1);
  }
}
#endif

static void TIMER4_init( void )
{
	__HAL_RCC_TIM4_CLK_ENABLE(  );

	HAL_NVIC_SetPriority( TIM4_IRQn, 6, 0 );
	HAL_NVIC_EnableIRQ( TIM4_IRQn );

	/* Compute the prescaler value */
	uint32_t pclk1 = HAL_RCC_GetPCLK1Freq();
	uint16_t prescaler = (uint16_t) ((pclk1 * 2) / timer4_clock) - 1;

	/* Time base configuration */
	timer4_handle.Instance           = TIM4;
	timer4_handle.Init.Period        = 65535;
	timer4_handle.Init.Prescaler     = prescaler;
	timer4_handle.Init.ClockDivision = 0;
	timer4_handle.Init.CounterMode   = TIM_COUNTERMODE_UP;
	
	if ( HAL_TIM_OC_Init( &timer4_handle ) != HAL_OK ) {
		Error_Handler();
	}

	/* Output Compare Timing Mode configuration: Channel1 */
	TIM_OC_InitTypeDef timer4_config;

	timer4_config.OCMode       = TIM_OCMODE_TIMING;
	timer4_config.OCIdleState  = TIM_OCIDLESTATE_SET;
	timer4_config.Pulse        = timer4_CCR1Val;
	timer4_config.OCPolarity   = TIM_OCPOLARITY_HIGH;
	timer4_config.OCNPolarity  = TIM_OCNPOLARITY_HIGH;
	timer4_config.OCFastMode   = TIM_OCFAST_ENABLE;
	timer4_config.OCNIdleState = TIM_OCNIDLESTATE_SET;

	/* Initialize the TIM4 Channel1 with the structure above */
	if ( HAL_TIM_OC_ConfigChannel( &timer4_handle, &timer4_config, TIM_CHANNEL_1 ) != HAL_OK ) {
		Error_Handler();
	}

	/* Start the Output Compare */
	if ( HAL_TIM_OC_Start_IT( &timer4_handle, TIM_CHANNEL_1 ) != HAL_OK ) {
		Error_Handler();
	}
}

void Error_Handler( void )
{
	LED_on( LED_0 );
	while ( 1 ) {
	}
}

void HAL_TIM_OC_DelayElapsedCallback( TIM_HandleTypeDef *htim )
{
	static uint32_t count = 0;
	
	uint32_t capture = 0;

	/* Get the TIM4 Input Capture 1 value */
	capture = HAL_TIM_ReadCapturedValue( htim, TIM_CHANNEL_1 );

	/* Set the TIM4 Capture Compare1 Register value */
	__HAL_TIM_SET_COMPARE( htim, TIM_CHANNEL_1, ( timer4_CCR1Val + capture ) );
	
	count ++;
	if( count >= 500 ) {
		LED_toggle( LED_3 );
		count = 0;
	}
}

void TIM4_IRQHandler( void )
{
	HAL_TIM_IRQHandler( &timer4_handle );
}

#ifdef USE_FULL_ASSERT
void assert_failed( uint8_t * file, uint32_t line )
{
	/* User can add his own implementation to report the file name and line number,
	   ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */

	/* Infinite loop */
	while ( 1 ) {
	}
}
#endif

int main( void )
{
	HAL_Init();

	SystemClock_Config();

	LED_init();

	TIMER4_init();

	while ( 1 ) {
		HAL_Delay(125);
		LED_toggle( LED_1 );
		HAL_Delay(125);
		LED_toggle( LED_1 );
		LED_toggle( LED_2 );
	}
}
