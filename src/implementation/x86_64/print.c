#include "print.h"

//video screen size
const static size_t NUM_COLS = 80;
const static size_t NUM_ROWS = 25;


// for each character
struct Characters{
    uint8_t character;
    uint8_t color;
};

//video memory address starting point
struct Characters* buffer = (struct Characters*) 0xb8000;

//current row,col track on screen
size_t col = 0;
size_t row = 0;

uint8_t color = PRINT_COLOR_WHITE | PRINT_COLOR_BLACK << 4;

//to clear row
void clear_row(size_t row) {
    struct Characters empty = (struct Characters) {
        character: ' ',
        color: color,
    };

    for (size_t col = 0; col < NUM_COLS; col++) {
        buffer[col + NUM_COLS * row] = empty;
    }
}

//to clear screen
void print_clear() {
    for (size_t i = 0; i < NUM_ROWS; i++) {
        clear_row(i);
    }
}

void print_newline() {
    col = 0;

    if (row < NUM_ROWS - 1) {
        row++;
        return;
    }

    for (size_t row = 1; row < NUM_ROWS; row++) {
        for (size_t col = 0; col < NUM_COLS; col++) {
            struct Characters character = buffer[col + NUM_COLS * row];
            buffer[col + NUM_COLS * (row - 1)] = character;
        }
    }

    clear_row(NUM_COLS - 1);
}

void print_char(char character) {
    if (character == '\n') {
        print_newline();
        return;
    }

    if (col > NUM_COLS) {
        print_newline();
    }

// updating character in buffer
    buffer[col + NUM_COLS * row] = (struct Characters) {
        character: (uint8_t) character,
        color: color,
    };

    col++;
}

void print_str(char* str) {
    for (size_t i = 0; 1; i++) {
        char character = (uint8_t) str[i];

        if (character == '\0') {
            return;
        }

        print_char(character);
    }
}

void print_set_color(uint8_t fg, uint8_t bg) {
    color = fg + (bg << 4);
}