arch gba.thumb

//==============================================================================
// Relocation hacks
//==============================================================================

// Move the weird box font from 0xFCE6C
org $80B3274; dd m2_font_relocate


//==============================================================================
// Font hacks
//==============================================================================

org $8AFED84; incbin m2-mainfont1-empty.bin
org $8B0F424; incbin m2-mainfont2-empty.bin
org $8B13424; incbin m2-mainfont3-empty.bin
org $8B088A4; incbin m2-shifted-cursor.bin

// Greek letters
org $8B1B907; db $8B // alpha
org $8B1B90A; db $8C // beta
org $8B1B90D; db $8D // gamma
org $8B1B910; db $8E // sigma
org $8B1B913; db $8F // omega


//==============================================================================
// VWF hacks
//==============================================================================

// 32- to 16-bit access change for window flags
org $80BE16A; strh r2,[r4,#0]
org $80BE1FA; strh r2,[r6,#0]
org $80BE222; strh r6,[r1,#0]

//---------------------------------------------------------
// C1FBC hacks (PSI window)
//---------------------------------------------------------

org $80C203E; mov r1,#0x14 // new entry length
org $80C21B4; mov r1,#0x14
org $80C224A; mov r1,#0x14
org $80C229E; mov r1,#0x14

//---------------------------------------------------------
// C438C hacks (PSI window cursor movement)
//---------------------------------------------------------

org $80C4580; bl m2_vwf_entries.c438c_moveup
org $80C4642; bl m2_vwf_entries.c438c_movedown
org $80C4768; bl m2_vwf_entries.c438c_moveright
org $80C48B2; bl m2_vwf_entries.c438c_moveleft

//---------------------------------------------------------
// PSI target window hacks
//---------------------------------------------------------

// PSI target length hack
org $80B8B12; mov r0,#0x14

// Fix PSI target offset calculation
org $80B8B08
mov     r1,#100
mul     r1,r2
nop
nop

// Make PP cost use correct number values
org     $80CA732
add     r1,#0x60

// Make PP cost use the correct space value if there's only one digit
org     $80CA712
mov     r0,#0x50

//---------------------------------------------------------
// C4B2C hacks (Equip window render)
//---------------------------------------------------------

// Start equipment at the 6th tile instead of 5th
org $80C4C96; mov r2,#6 // Weapon
org $80C4D1C; mov r2,#6 // Body
org $80C4DA4; mov r2,#6 // Arms
org $80C4E2C; mov r2,#6 // Other

// Only render (None) if necessary
org     $80C4C0C
bl      m2_vwf_entries.c4b2c_skip_nones
b       $80C4C58

// Don't render equip symbols
org $80C4CD0; nop
org $80C4CDE; nop
org $80C4D58; nop
org $80C4D66; nop
org $80C4DE0; nop
org $80C4DEE; nop
org $80C4E68; nop
org $80C4E76; nop

//---------------------------------------------------------
// C4B2C hacks (Equip window loop)
//---------------------------------------------------------

org $80C4F80; bl m2_vwf_entries.c4b2c_clear_left
org $80C4F84; bl m2_vwf_entries.c4b2c_clear_right

//---------------------------------------------------------
// C980C hacks
//---------------------------------------------------------

// Reset pixel X during a newline
org     $80C9CC4
bl      m2_vwf_entries.c980c_resetx_newline

// Custom codes check
org     $80CA2BC
bl      m2_vwf_entries.c980c_custom_codes

// Reset pixel X when redrawing the window
org     $80CA2E6
bl      m2_vwf_entries.c980c_resetx

// Welding entry
org     $80CA448
bl      m2_vwf_entries.c980c_weld_entry
b       $80CA46C

// Disable X coordinate incrementing
org     $80CA48E
nop

//---------------------------------------------------------
// C87D0 hacks
//---------------------------------------------------------

org     $80C87DC
bl      m2_vwf_entries.c87d0_clear_entry

//---------------------------------------------------------
// C9634 hacks
//---------------------------------------------------------

org     $80C967E
bl      m2_vwf_entries.c9634_resetx

//---------------------------------------------------------
// C96F0 hacks
//---------------------------------------------------------

org     $80C9714
lsl     r3,r3,#1 // change from row coords to tile coords
ldrh    r1,[r0,#0x22]
add     r1,r1,r2
lsl     r1,r1,#3 // r1 = tile_x * 8
ldrh    r2,[r0,#0x24]
add     r2,r2,r3
lsl     r2,r2,#3 // r2 = tile_y * 8
mov     r0,r6
bl      m2_vwf.print_string
mov     r7,r0
b       $80C9788

//==============================================================================
// Data files
//==============================================================================

org $8B2C000

// Box font relocation
m2_font_relocate:
incbin m2-font-relocate.bin

// Co-ordinate table
m2_coord_table:
incbin m2-coord-table.bin

// EB fonts
m2_font_table:
dd     m2_font_main
dd     m2_font_saturn

m2_font_main:
incbin m2-font-main.bin

m2_font_saturn:
incbin m2-font-saturn.bin

// EB font heights
m2_height_table:
db     $02, $02, $01, $00    // last byte for alignment

// EB font widths
m2_widths_table:
dd     m2_widths_main
dd     m2_widths_saturn

m2_widths_main:
incbin m2-widths-main.bin

m2_widths_saturn:
// tbd

m2_bits_to_nybbles:
incbin m2-bits-to-nybbles.bin

m2_nybbles_to_bits:
incbin m2-nybbles-to-bits.bin


//==============================================================================
// Misc
//==============================================================================

org $2027FC0
m2_custom_wram:


//==============================================================================
// Code files
//==============================================================================

org $80FCE6C
incsrc m2-vwf.asm
incsrc m2-vwf-entries.asm
incsrc m2-formatting.asm
incsrc m2-customcodes.asm
