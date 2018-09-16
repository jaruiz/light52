/**



    


*/

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>

#include "b51_cpu.h"
#include "b51_mcu.h"
#include "b51_debug.h"
#include "b51_log.h"

/*-- Private data & data types -----------------------------------------------*/

#define BUFSIZE (4096)

/* All valid command characters, for quick sanity check purposes. */
const char *VALID_CMD_CHARS = "VZRXIDC";

const char *BASE64_CHARS =  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                            "abcdefghijklmnopqrstuvwxyz"
                            "0123456789+/";

static char rxbuf[BUFSIZE];
static char txbuf[BUFSIZE];




/*-- Local function prototypes -----------------------------------------------*/

static void cmd_trim(char *cmd);
static int cmd_sanity_check(const char *cmd);
static uint32_t cmd_get_hex_field(const char *cmd, int start, int len);
static void resp_send(FILE *tty, const char *resp);
static uint8_t compute_checksum(const char *s, int len);
static void respond(FILE *tty, const char *msg, cpu51_t *cpu);
static void base64_encode(char *dest, uint8_t *data, int len);
static char base64_encode_byte(uint8_t b);


/*-- Public functions --------------------------------------------------------*/

extern int debug_target(cpu51_t *cpu, const char *ttyfname){
    uint32_t cmdlen;
    FILE *tty;

    printf("Listening for debug commands on virtual tty %s\n", ttyfname);
    fflush(stdout);

    tty = fopen(ttyfname, "r+");
    if (tty == NULL) {
        perror("Error opening input tty device");
        return 1;
    }

    while(!feof(tty)){
        fgets(rxbuf, BUFSIZE, tty);
        cmd_trim(rxbuf);
        if(!cmd_sanity_check(rxbuf)) {
            resp_send(tty, "?");
        }
        else {
            respond(tty, rxbuf, cpu);
        }
    }

    fclose(tty);

    return 0;
}


/*-- Local functions ---------------------------------------------------------*/

static void respond(FILE *tty, const char *msg, cpu51_t *cpu){
    uint32_t addr, r0ix, nn;
    char buf[512]; // FIXME parameter

    if (msg[1]=='V') {
        /* V: Query interface version. */
        resp_send(tty, "V01000000");
    }
    else if(msg[1]=='Z') {
        /* Z: Reset CPU. */
        addr = cmd_get_hex_field(msg,2,6);
        if (addr < MAX_XCODE_SIZE) {
            cpu_reset(cpu);
            cpu->pc = (uint16_t)addr;
            resp_send(tty, "Z");
        }
        else{
            /* Bad PC value: error. */
            resp_send(tty, "");
        }
    } 
    else if(msg[1]=='R') {
        /* R: Query values of main registers. */
        r0ix = cpu->sfr.psw & 0x18;
        sprintf(buf, 
            "R%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x\n",
            cpu->idata[r0ix + 0],
            cpu->idata[r0ix + 1],
            cpu->idata[r0ix + 2],
            cpu->idata[r0ix + 3],
            cpu->idata[r0ix + 4],
            cpu->idata[r0ix + 5],
            cpu->idata[r0ix + 6],
            cpu->idata[r0ix + 7],
            cpu->a,
            0x00,
            (cpu->pc >> 8) & 0xff,
            (cpu->pc >> 0) & 0xff);

        resp_send(tty, buf);
    }
    else if(msg[1]=='X') {
        /* X: Execute N instructions. */
        nn = cmd_get_hex_field(msg,2,2);
        cpu_exec(cpu, nn);
        sprintf(buf, "X%06x", (uint32_t)cpu->pc);
        resp_send(tty, buf);
    }
    else if(msg[1]=='I') {
        /* I: Read N bytes from IRAM starting at A. */
        addr = cmd_get_hex_field(msg,2,2);
        nn = cmd_get_hex_field(msg,4,2);
        if ((addr >= MAX_IDATA_SIZE) || ((addr + nn > MAX_IDATA_SIZE)) ||
            (((nn*4)/3) > (sizeof(buf) - 2)) ){
            resp_send(tty, ""); /* Out of bounds -- error. */    
        }
        else {
            buf[0] = 'I';
            base64_encode(&(buf[1]), &(cpu->idata[addr]), nn);
            resp_send(tty, buf);
        }
    }
    else if(msg[1]=='C') {
        /* C: Read N bytes from XCODE starting at A. */
        addr = cmd_get_hex_field(msg,2,6);
        nn = cmd_get_hex_field(msg,4,2);
        if ((addr >= MAX_XCODE_SIZE) || ((addr + nn) > MAX_XCODE_SIZE) ||
            (((nn*4)/3) > (sizeof(buf) - 2)) ){
            resp_send(tty, ""); /* Out of bounds -- error. */    
        }
        else {
            buf[0] = 'C';
            base64_encode(&(buf[1]), &(cpu->mcu.xcode[addr]), nn);
            resp_send(tty, buf);
        }
    }
    else if(msg[1]=='D') {
        /* D: Read N bytes from XDATA starting at A. */
        addr = cmd_get_hex_field(msg,2,6);
        nn = cmd_get_hex_field(msg,4,2);
        if ((addr >= MAX_XDATA_SIZE) || ((addr + nn) > MAX_XDATA_SIZE) ||
            (((nn*4)/3) > (sizeof(buf) - 2)) ){
            resp_send(tty, ""); /* Out of bounds -- error. */    
        }
        else {
            buf[0] = 'D';
            base64_encode(&(buf[1]), &(cpu->mcu.xdata[addr]), nn);
            resp_send(tty, buf);
        }
    }
    else {
        /* Unknown command. */
        resp_send(tty, "??");
    }
}

static void resp_send(FILE *tty, const char *resp) {
    uint8_t csum = compute_checksum(resp, strlen(resp));
    snprintf(txbuf, BUFSIZE, "$%s#%02x\n", resp, csum);

    fprintf(tty, "%s", txbuf);
    fflush(tty);
}


static uint32_t cmd_get_hex_field(const char *cmd, int start, int len) {
    char field[10];
    uint32_t val, i;

    for (i=0; i<len && cmd[start+i]!='\0' && i<8; i++){
        field[i] = cmd[start+i];
        if (!isxdigit(field[i])) return 0;
    }
    field[i] = '\0';

    val = (uint32_t)strtol(field, NULL, 16);

    return val;
}

/* Trim leading and trailing whitespace in place, return final string length. */
static void cmd_trim(char *cmd) {
    uint32_t i = 0, start;
    while(isspace(cmd[i])) i++;

    start = i;
    while(i<BUFSIZE && cmd[i]!='\0' && !isspace(cmd[i])) {
        cmd[i] = cmd[start+i];
        i++;
    }

    if (i<BUFSIZE && isspace(cmd[i])) {
        cmd[i] = '\0';
    }
}

/* Return 1 if the command string seems kosher and checksum matches.

   NOTE: This would be cleaner with POSIX regexes but I don't want to go to the 
   trouble of securing this thing against serial port garbage. 
*/
static int cmd_sanity_check(const char *cmd) {
    int len;
    char cmdchar;
    uint8_t csum, cmd_csum;

    len = strlen(cmd);
    if (len<5) return 0;

    if (cmd[0]!='$') return 0;

    cmdchar = cmd[1];
    if (strchr(VALID_CMD_CHARS, cmdchar)==NULL) return 0;

    /* Ok, now look at the shape of the command tail... */
    if (cmd[len-3]!='#') return 0;
    /* TODO swallow uppercase hex digits even though protocol forbids them. */
    if (!isxdigit(cmd[len-2])) return 0;
    if (!isxdigit(cmd[len-1])) return 0;

    /* ...and finally verify the checksum. */
    cmd_csum = strtol(&(cmd[len-2]), NULL, 16);
    csum = compute_checksum(&(cmd[1]), len-4);    
    if (csum != cmd_csum) return 0;

    return 1;
} 

static uint8_t compute_checksum(const char *s, int len){
    uint8_t csum = 0, c;
    int i;
    for(i=0; i<len && s[i]!='\0'; i++) {
        c = (uint8_t)s[i];
        csum += c;
    }
    return csum;
}

static void base64_encode(char *dest, uint8_t *data, int len) {
    char quantum[5];
    uint32_t w;
    int i=0, j, odd;

    strcpy(dest, "");

    while (i < len) {
        w = 0;
        odd = 0;
        for(j=0; j<3; j++){ 
            if ((i+j)>=len) odd ++;
            w = (w << 8) + (((i+j)>=len)? 0 : data[i+j]);
        }
        quantum[0] = base64_encode_byte((w >> 18) & 0x3f);
        quantum[1] = base64_encode_byte((w >> 12) & 0x3f);
        quantum[2] = base64_encode_byte((w >>  6) & 0x3f);
        quantum[3] = base64_encode_byte((w >>  0) & 0x3f);
        quantum[4] = '\0';
        if (odd >= 2) quantum[2]='=';
        if (odd >= 1) quantum[3]='=';
        strcat(dest, quantum);
        i += 3;
    }

}

static char base64_encode_byte(uint8_t b){
    return BASE64_CHARS[b & 0x3f];
}
