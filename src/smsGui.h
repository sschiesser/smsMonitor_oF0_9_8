#pragma once

/* --------------------------------------------------------------
*     MACROS
* -------------------------------------------------------------- */
<<<<<<< HEAD
#define GUI_WINDOW_WIDTH                    560
=======
#define GUI_WINDOW_WIDTH                    350
>>>>>>> ofxBle_Win
#define GUI_WINDOW_HEIGHT                   720
#define GUI_HEADER_WIDTH                    GUI_WINDOW_WIDTH
#define GUI_HEADER_HEIGHT                     48

//#define GUI_MODULE_WIDTH                  (GUI_WINDOW_WIDTH / 4)
<<<<<<< HEAD
#define GUI_MOD_SENSORS_WIDTH            360
#define GUI_MOD_SENSORS_HEIGHT          720
=======
#define GUI_MOD_SENSORS_WIDTH            (GUI_WINDOW_WIDTH)
#define GUI_MOD_SENSORS_HEIGHT          520
>>>>>>> ofxBle_Win
#define GUI_MOD_REMOTE_WIDTH            GUI_MOD_SENSORS_WIDTH
#define GUI_MOD_REMOTE_HEIGHT           (GUI_WINDOW_HEIGHT - GUI_MOD_SENSORS_HEIGHT)

#define GUI_MOD_SENSORS_POS_Y		GUI_HEADER_HEIGHT
#define GUI_MOD_SENSORS_POS_X0		0
#define GUI_MOD_SENSORS_POS_X1		GUI_MODULE_WIDTH
#define GUI_MOD_SENSORS_POS_X2		(2 * GUI_MODULE_WIDTH)
#define GUI_MOD_SENSORS_POS_X3		(3 * GUI_MODULE_WIDTH)

#define GUI_MOD_REMOTE_POS_Y	(GUI_HEADER_HEIGHT + GUI_MOD_SENSORS_HEIGHT)
#define GUI_MOD_REMOTE_POS_X0	GUI_MOD_SENSORS_POS_X0
#define GUI_MOD_REMOTE_POS_X1	GUI_MOD_SENSORS_POS_X1
#define GUI_MOD_REMOTE_POS_X2	GUI_MOD_SENSORS_POS_X2
#define GUI_MOD_REMOTE_POS_X3	GUI_MOD_SENSORS_POS_X3

/* --------------------------------------------------------------
*     CLASSES
* -------------------------------------------------------------- */


/* --------------------------------------------------------------
*     VARIABLES
* -------------------------------------------------------------- */
