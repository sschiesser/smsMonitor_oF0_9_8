#pragma once

/* --------------------------------------------------------------
*     MACROS
* -------------------------------------------------------------- */
#define GUI_WINDOW_WIDTH		1400
#define GUI_WINDOW_HEIGHT		960
#define GUI_HEADER_WIDTH		GUI_WINDOW_WIDTH
#define GUI_HEADER_HEIGHT		48

#define GUI_MODULE_WIDTH		(GUI_WINDOW_WIDTH / 4)
#define GUI_MODULE_HEIGHT		800
#define GUI_MOD_REMOTE_WITH		GUI_MODULE_WIDTH
#define GUI_MOD_REMOTE_HEIGHT	160

#define GUI_MODULE_POS_Y		GUI_HEADER_HEIGHT
#define GUI_MODULE_POS_X0		0
#define GUI_MODULE_POS_X1		GUI_MODULE_WIDTH
#define GUI_MODULE_POS_X2		(2 * GUI_MODULE_WIDTH)
#define GUI_MODULE_POS_X3		(3 * GUI_MODULE_WIDTH)

#define GUI_MOD_REMOTE_POS_Y	(GUI_HEADER_HEIGHT + GUI_MODULE_HEIGHT)
#define GUI_MOD_REMOTE_POS_X0	0
#define GUI_MOD_REMOTE_POS_X1	GUI_MODULE_POS_X1
#define GUI_MOD_REMOTE_POS_X2	GUI_MODULE_POS_X2
#define GUI_MOD_REMOTE_POS_X3	GUI_MODULE_POS_X3

/* --------------------------------------------------------------
*     CLASSES
* -------------------------------------------------------------- */


/* --------------------------------------------------------------
*     VARIABLES
* -------------------------------------------------------------- */
