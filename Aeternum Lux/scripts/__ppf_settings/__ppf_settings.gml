
/*----------------------------------------------------------------------------------------------
	Here you can modify some library behaviors.
	You don't need to call this script, it runs automatically.
	
	If you want to change the quality of Motion Blur, Radial Blur and others, modify the
	"ITERATIONS" variable of each one in the pixel shader.
----------------------------------------------------------------------------------------------*/

// enable debug messages from Post-Processing FX
#macro PPFX_CFG_TRACE_ENABLE true

// enable error checking of Post-Processing FX functions (disabling this will increase CPU-side performance)
#macro PPFX_CFG_ERROR_CHECKING_ENABLE true

// enable hardware compatibility checking
#macro PPFX_CFG_HARDWARE_CHECKING true

// time (in seconds) to reset the global PPFX timer (-1 for unlimited)
// useful for Mobile devices
#macro PPFX_CFG_TIMER 3600 // 60 minutes (1 hour) = 3600 seconds

// global effects speed ( 1/60 = 0.016 ) >> 60 is the game speed, in frames per second
#macro PPFX_CFG_SPEED 0.016
