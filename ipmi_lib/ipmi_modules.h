//*****************************************************************************
//
// IPMI Modules Header File
//
// author:  qujianning@kyland.com.cn
// update:  2012/08/03
// version: v1.0
//
//*****************************************************************************

#ifndef _IPMI_MODULES_H_
#define _IPMI_MODULES_H_

//
// ����忨����
//
//#define BOARD_6911_FAN
//#undef  BOARD_6911_FAN

//#define BOARD_6911_POWER
//#undef  BOARD_6911_POWER

//#define BOARD_6911_SWITCH
//#undef  BOARD_6911_SWITCH

//#define BOARD_6911_FABRIC
//#undef  BOARD_6911_FABRIC

#if !defined(BOARD_6911_FAN) && !defined(BOARD_6911_POWER) && !defined(BOARD_6911_SWITCH)  && !defined(BOARD_6911_FABRIC)
#error Must define a ARM BOARD
#endif

//
// �������оƬ
//
#ifdef  BOARD_6911_FAN
#define IPMI_CHIP_ADT7470               // ���ȼ�ش�����
#define IPMI_CHIP_AT24CXX               // EEPROM�洢��
#define IPMI_CHIP_MC_LOCATOR            // �忨�б�
#endif

#ifdef  BOARD_6911_POWER
#define IPMI_CHIP_MAX6635               // �¶ȼ�ش�����
#define IPMI_CHIP_INA230                // ��ѹ������ش�����
#define IPMI_CHIP_AT24CXX               // EEPROM�洢��
#define IPMI_CHIP_MC_LOCATOR            // �忨�б�
#endif

#ifdef  BOARD_6911_SWITCH
#define IPMI_CHIP_MAX6635               // �¶ȼ�ش�����
#define IPMI_CHIP_UCD9081               // ��ѹ��ش�����
#define IPMI_CHIP_AT24CXX               // EEPROM�洢��
#define IPMI_CHIP_PCF8563               // ʵʱʱ��оƬ
#define IPMI_CHIP_LOGIC                 // ϵͳ�߼�оƬ
#define IPMI_CHIP_MC_LOCATOR            // �忨�б�
#endif

#ifdef  BOARD_6911_FABRIC
#define IPMI_CHIP_MAX6635               // �¶ȼ�ش�����
#define IPMI_CHIP_UCD9081               // ��ѹ��ش�����
#define IPMI_CHIP_AT24CXX               // EEPROM�洢��
#define IPMI_CHIP_PCF8563               // ʵʱʱ��оƬ
#define IPMI_CHIP_LOGIC                 // ϵͳ�߼�оƬ
#define IPMI_CHIP_MC_LOCATOR            // �忨�б�
#endif

//
// ����IPMI���ܽӿ�
//
#ifdef  BOARD_6911_FAN
#define IPMI_MODULES_I2C0_IPMB
#define IPMI_MODULES_I2C1_HARD_PMB
#define IPMI_MODULES_UART0_DEBUG
#define IPMI_MODULES_GPIO_CPU_LED
#define IPMI_MODULES_GPIO_PRESENT
#define IPMI_MODULES_GPIO_PRESENT_FAB
#define IPMI_MODULES_GPIO_SLOT_ADDR
#define IPMI_MODULES_GPIO_BOARD_TYPE
#define IPMI_MODULES_GPIO_I2C_HOTSWAP_SEL
#define IPMI_MODULES_GPIO_WATCHDOG
#define IPMI_MODULES_GPIO_FULL_SPEED
#endif

#ifdef  BOARD_6911_POWER
#define IPMI_MODULES_I2C0_IPMB
#define IPMI_MODULES_I2C1_HARD_PMB
#define IPMI_MODULES_UART0_DEBUG
#define IPMI_MODULES_GPIO_CPU_LED
#define IPMI_MODULES_GPIO_PRESENT
#define IPMI_MODULES_GPIO_PRESENT_FAB
#define IPMI_MODULES_GPIO_SLOT_ADDR
#define IPMI_MODULES_GPIO_BOARD_TYPE
#define IPMI_MODULES_GPIO_GOOD_FAB
#define IPMI_MODULES_GPIO_WATCHDOG
#endif

#if (defined(BOARD_6911_SWITCH) || defined(BOARD_6911_FABRIC))
#define IPMI_MODULES_I2C0_IPMB
#define IPMI_MODULES_I2C1_HARD_PMB
#define IPMI_MODULES_SPI0_CPLD
#define IPMI_MODULES_SPI1_SSIF
#define IPMI_MODULES_ETH_LAN
#define IPMI_MODULES_UART0_DEBUG
#define IPMI_MODULES_UART1_ICMB
#define IPMI_MODULES_UART2_SOL
#define IPMI_MODULES_GPIO_CPU_LED
#define IPMI_MODULES_GPIO_SOL_SEL
#define IPMI_MODULES_GPIO_I2C_HOTSWAP_SEL
#define IPMI_MODULES_GPIO_SLOT_ADDR
#define IPMI_MODULES_GPIO_WATCHDOG
#define IPMI_MODULES_GPIO_CPU_INT_ALARM
#define IPMI_MODULES_GPIO_FPGA_INT_ALARM
#define IPMI_MODULES_SESSION
#define IPMI_MODULES_PAYLOAD
#define IPMI_MODULES_SOL
#endif


#define IPMI_DEV_SOL            (1 << 8)
#define IPMI_DEV_CHASSIS        (1 << 7)
#define IPMI_DEV_BRIDGE         (1 << 6)
#define IPMI_DEV_IPMB_EG        (1 << 5)
#define IPMI_DEV_IPMB_ER        (1 << 4)
#define IPMI_DEV_FRU            (1 << 3)
#define IPMI_DEV_SEL            (1 << 2)
#define IPMI_DEV_SDR            (1 << 1)
#define IPMI_DEV_SENSOR         (1 << 0)

#define IPMI_DEV_DEVICE_ADT       \
        (IPMI_DEV_CHASSIS       | \
         IPMI_DEV_SEL           | \
         IPMI_DEV_SENSOR)

#define IPMI_DEVICE_NORMAL_OPERATION    0
#define IPMI_DEVICE_FIRMWARE            1


#endif  // _IPMI_MODULES_H_

