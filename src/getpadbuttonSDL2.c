#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/select.h>
#include <termios.h>
#include <SDL2/SDL.h>

struct termios orig_termios;

void reset_terminal_mode()
{
    tcsetattr(0, TCSANOW, &orig_termios);
}

void set_conio_terminal_mode()
{
    struct termios new_termios;

    /* take two copies - one for now, one for later */
    tcgetattr(0, &orig_termios);
    memcpy(&new_termios, &orig_termios, sizeof(new_termios));

    /* register cleanup handler, and set the new terminal mode */
    atexit(reset_terminal_mode);
    cfmakeraw(&new_termios);
    tcsetattr(0, TCSANOW, &new_termios);
}

int kbhit()
{
    struct timeval tv = { 0L, 0L };
    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(0, &fds);
    return select(1, &fds, NULL, NULL, &tv) > 0;
}

int getch(unsigned char *buffer)
{
    int r;
    unsigned char c[5];
    if ((r = read(0, c, sizeof(c))) < 0) {
        return r;
    } else {
        if (r == 1) {
            switch(c[0]) {
                case ' ':
                    sprintf(buffer, "space");
                    break;
                case 9:
                    sprintf(buffer, "tab");
                    break;
                case 13:
                    sprintf(buffer, "enter");
                    break;
                case 27:
                    sprintf(buffer, "escape");
                    break;
                case 127:
                    sprintf(buffer, "backspace");
                    break;
                default:
                    sprintf(buffer, "%c", c[0]);            
            } 
            return 0;
        } else if (c[0] == 27 && r == 3) {
            switch(c[2]) { // the real value
                case 'A':
                    sprintf(buffer, "up");
                    break;
                case 'B':
                    sprintf(buffer, "down");
                    break;
                case 'C':
                    sprintf(buffer, "right");
                    break;
                case 'D':
                    sprintf(buffer, "left");
                    break;
                case 'F':
                    sprintf(buffer, "end");
                    break;                    
                case 'H':
                    sprintf(buffer, "home");
                    break;                    
                case 'P':
                    sprintf(buffer, "f1");
                    break;
                case 'Q':
                    sprintf(buffer, "f2");
                    break;                    
                case 'R':
                    sprintf(buffer, "f3");
                    break;
                case 'S':
                    sprintf(buffer, "f4");
                    break;                    
                default:
                    sprintf(buffer, "Unknown %d %c", c[2], c[2]);
                    
            }
            return 0;
        } else if (c[0] == 27 && r == 5) {
            switch(c[3]) { // the real value
               case '5':
                    sprintf(buffer, "f5");
                    break;
                case '7':
                    sprintf(buffer, "f6");
                    break;                    
                case '8':
                    sprintf(buffer, "f7");
                    break;
                case '9':
                    sprintf(buffer, "f8");
                    break;                  
                case '0':
                    sprintf(buffer, "f9");
                    break;
                case '1':
                    sprintf(buffer, "f10");
                    break;                      
                case '3':
                    sprintf(buffer, "f11");
                    break;                      
                case '4':
                    sprintf(buffer, "f12");
                    break;                     
                default:
                    sprintf(buffer, "Unknown %d %c", c[3], c[3]);
                    
            }            
        } else {
            sprintf(buffer, "Unknown length %d", r);
        }
    }
    return -1;
}

int main(int argc, char **argv) {
    int opt;
    int text = 0;
    int padonly = 0;
    int keyonly = 0;
    char buffer[256];
    
    SDL_GameController* gamepad;

    while ((opt = getopt(argc, argv, "kpnt:")) != -1 ) {
        switch(opt) {
            case 'p': 
                padonly = 1; 
                break;
            case 'k': 
                keyonly = 1; 
                break;
            case 'n': 
                // Initialize SDL2
                if (SDL_Init(SDL_INIT_GAMECONTROLLER) != 0) {
                    printf("SDL initialization failed: %s\n", SDL_GetError());
                    return 1;
                }            
                int numGamepads = SDL_NumJoysticks();
                printf("Gamepads detected: %d\n", numGamepads);
                SDL_Quit();
                return 0;
            case 't':
                strcpy(buffer, optarg);
                text = 1;
                break;
            case 'h':
            default:
                fprintf(stderr, "Usage: %s [-pn] [-t text]\n\n   -h: Prints this help.\n   -p: Read gamepad buttons only.\n   -k: Read keyboard only.\n   -n: Check for connected gamepads.\n   -t: Prints text before waiting for input.\n", argv[0]);
                SDL_Quit();
                return 1;
                
        }
    }
    
    if (!keyonly) {
    
        // Initialize SDL2
        if (SDL_Init(SDL_INIT_GAMECONTROLLER) != 0) {
            printf("SDL initialization failed: %s\n", SDL_GetError());
            return 1;
        }

        // Open the first gamepad
        gamepad = SDL_GameControllerOpen(0);
        if (!gamepad) {
            fprintf(stderr, "Failed to open gamepad: %s\n", SDL_GetError());
            SDL_Quit();
            return 1;
        }
    }

    // printf("Gamepad connected: %s\n", SDL_GameControllerName(gamepad));

    // Event loop
    SDL_Event event;
    set_conio_terminal_mode();    
    if (text)
        fprintf(stderr,"%s\r\n", buffer);
    while (1) {
        if (!keyonly && SDL_PollEvent(&event)) {
            if (event.type == SDL_CONTROLLERBUTTONUP) {
                int button = event.cbutton.button;
                const char* buttonName = SDL_GameControllerGetStringForButton(button);
                printf("Button: %s\r\n", buttonName);
                
                // Clean up
                SDL_GameControllerClose(gamepad);
                SDL_Quit();
                return 0;
            } 
        } else if (!padonly && kbhit()) {
            int key = getch(buffer); /* consume the character */
            printf("Key: %s\r\n", buffer);
            
            // Clean up
            if (!keyonly) {
                SDL_GameControllerClose(gamepad);
                SDL_Quit();
            }
            return 0;

        }
    }

    // Clean up
    if (!keyonly) {
        SDL_GameControllerClose(gamepad);
        SDL_Quit();
    }
    return 0;
}

