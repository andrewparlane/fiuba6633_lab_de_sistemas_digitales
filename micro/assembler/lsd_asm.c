/**************************************************************************

  Copyright (c) 2013
  Federico Giordano Zacchigna (federico.zacchigna@gmail.com)

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; version 2.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.

***************************************************************************/

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

typedef struct link_s {
  char* name;
  unsigned int memPos;
  unsigned int line;
  struct link_s* next;
} link_t;

typedef link_t* linksList_t;

typedef enum functionType_e {
  TYPE_ONE_OP = 0,
  TYPE_TWO_OP = 1
} functionType_t;

typedef struct instruction_s {
  functionType_t type;
  char function[16];
  char aOperand[16];
  char bOperand[16];
  unsigned int instructionNumber;
  unsigned int lineNumber;
  struct instruction_s* next;
} instruction_t;

typedef instruction_t* instructionList_t;

typedef struct api_s {
  char* name;
  functionType_t type;
  unsigned char opcode;
} api_t;

api_t instructionName[] = {
  // Type two operands
  {"load",  TYPE_TWO_OP,0x00},
  {"store", TYPE_TWO_OP,0x01},
  {"loadi", TYPE_TWO_OP,0x02},
  {"storei",TYPE_TWO_OP,0x03},

  {"add",   TYPE_TWO_OP,0x40},
  {"sub",   TYPE_TWO_OP,0x41},
  {"addc",  TYPE_TWO_OP,0x42},
  {"subc",  TYPE_TWO_OP,0x43},

  {"addi",  TYPE_TWO_OP,0x44},
  {"subi",  TYPE_TWO_OP,0x45},
  {"addic", TYPE_TWO_OP,0x46},
  {"subic", TYPE_TWO_OP,0x47},

  {"nor",   TYPE_TWO_OP,0x80},
  {"nand",  TYPE_TWO_OP,0x81},
  {"xor",   TYPE_TWO_OP,0x82},
  {"xnor",  TYPE_TWO_OP,0x83},

  {"nori",  TYPE_TWO_OP,0x84},
  {"nandi", TYPE_TWO_OP,0x85},
  {"xori",  TYPE_TWO_OP,0x86},
  {"xnori", TYPE_TWO_OP,0x87},

  // Type one operands
  {"jump",  TYPE_ONE_OP,0xc0},
  {"jz",    TYPE_ONE_OP,0xc1},
  {"jc",    TYPE_ONE_OP,0xc2},
  {"jn",    TYPE_ONE_OP,0xc3},
};

int main (int argc, char * argv[]) {
   FILE * inputFile;
   FILE * outputFile;
   FILE * dumpFile;
   char str[1024];
   char function[16];
   char aOperand[16];
   char bOperand[16];
   int line;
   int operands;
   int instCount;
   int error;
   int i, j, k;
   unsigned int value;

   puts ("");
   puts ("#############################################################");
   puts ("#                                                           #");
   puts ("#                    Assembler Program                      #");
   puts ("#                                                           #");
   puts ("#############################################################");
   puts ("#                                                           #");
   puts ("#  Version 1.0                                              #");
   puts ("#  Sep. 30, 2014                                            #");
   puts ("#                                                           #");
   puts ("#############################################################");
   puts ("");
   puts ("");
   puts ("");

   linksList_t linksList = NULL;
   instructionList_t instructionsList;
   instructionsList = NULL;

   error = 0;
   instCount = 0;
   line = 0;
   if (argc!=3) {
      error = 1;
      puts ("ERROR: Bad input arguments.");
      puts ("");
      puts ("USAGE: ./lsdasm <inputFile> <outputFile>");
      puts ("");
      puts ("");
      return 0;
   }
   if ((inputFile = fopen(argv[1],"r"))==NULL) {
      error = 1;
      printf ("ERROR 0: Invalid name for input file. Check it has access.\n");
      puts ("");
      puts ("");
      return -1;
   }

   dumpFile = fopen ("code.lst","w");
   outputFile = fopen (argv[2],"w");

   while (fgets(str,1024,inputFile)!=NULL) {
      if (ferror(inputFile)) {
         printf ("ERROR 1: Wrong input file.\n");
         puts ("");
         puts ("");
         return -1;
      }
      line++;
      int i,j=0;

      operands = 2;

      // Remove initial spaces and tabulators
      for (i=0;i<1024;++i) {
         if ((str[i]!='\t') && (str[i]!=' ')) {
            break;
         }
      }

      for (;i<1024;++i) {
         str[j++]=str[i];
         // Remove everything after first ';' or ':'
         if (str[i]==';' || str[i]==':') {
            str[j++]='\n';
            str[j]='\0';
            break;
         }
      }

      // Remove all empty lines
      if (str[0]!='\n' && str[0]!='\r' && str[0]!='#') {
         // Check for ';' or "$xxxx:" at end of line
         for (i=0;i<1024;++i) {
            if (str[i]==';') {
               i=1024;
            } else if (str[i]==':') {
               i = 1024;
               if (str[0]!='$') {
                  error = 1;
                  printf ("ERROR 3: No \"$.....:\" found at end of line \"%d\".\n",line);
               }
            } else if (str[i]=='\n' || str[i]=='\r' || str[i]=='#' || str[i]=='\0'|| i==1023) {
               error = 1;
               printf ("ERROR 2: No ';' found at end of line \"%d\".\n",line);
               break;
            }
         }

         // Check for '$' at the beginning or for ' ' after function
         if (str[0]=='$') {
            operands = 0;
         } else {
            for (i=0;i<1024;++i) {
               if((str[i]==' ') || (str[i]=='\t')) {
                  str[i] = '#';
                  instCount++;
                  break;
               }
               if ((str[i]==';') || (str[i]=='\n') || str[i]=='\r' || (str[i]=='\0')) {
                  error = 1;
                  printf ("ERROR 4: No ' ' found before operands in line \"%d\".\n",line);
                  break;
               }
            }
            j = i;
            for (;i<1024;++i) {
               if((str[i] != ' ') && (str[i] != '\t')) {
                  str[j++] = str[i];
               }
            }
         }

         // Extract function operands A and B or add link to list
         if (operands>0) {
            for (i=0,j=0;i<1024;++i) {
               if (str[i]!='#') {
                  function[j++] = str[i];
               } else {
                  break;
               }
            }
            function[j] = '\0';
            for (i++,j=0;i<1024;++i) {
               if (str[i]!=',' && str[i]!=';') {
                  aOperand[j++] = str[i];
               } else {
                  break;
               }
            }
            aOperand[j] = '\0';
            j = 0;
            if (str[i]==',') {
               for (i++,j=0;i<1024;++i) {
                  if (str[i]!=';') {
                     bOperand[j++] = str[i];
                  } else {
                     break;
                  }
               }
               bOperand[j] = '\0';
            } else {
               bOperand[0] = '\0';
               operands = 1;
            }
            if (operands==1) {
               fprintf (dumpFile,"0x%02x: \t%s\t%s;\n",(instCount-1)*2,function,aOperand);
            } else {
               fprintf (dumpFile,"0x%02x: \t%s\t%s, %s;\n",(instCount-1)*2,function,aOperand,bOperand);
            }
         } else {
            str[strlen(str)-2]='\0';
            fprintf (dumpFile,"\n0x%02x: \t<%s>:\n",(instCount)*2,str);

            // Add to linksList
            link_t* aux = (link_t*) malloc(sizeof(link_t));
            aux->name = (char*) malloc(strlen(str)*sizeof(char));
            for (i=0;i<strlen(str);i++) {
               aux->name[i] = str[i];
            }
            aux->memPos = instCount;
            aux->line = line;
            aux->next=NULL;
            if (linksList==NULL) {
               linksList = aux;
            } else {
               link_t * aux2 = linksList;
               while (aux2->next && (strcmp(aux2->name,str)!=0)) {
                  aux2 = aux2->next;
               }
               if (strcmp(aux2->name,str)!=0) {
                  aux2->next = aux;
               } else {
                  error = 1;
                  printf ("ERROR 5: Reference \"%s\" multiple defined: line %d\n first defined in line %d.\n",str,line,aux2->line);
                  free (aux);
               }
            }
         }

         // Function and operands in lower case
         for (i=0;i<16;++i) {
            function[i] = (function[i]=='\n'||function[i]=='\r')?'\0':(char)tolower((int)function[i]);
            aOperand[i] = (aOperand[i]=='\n'||aOperand[i]=='\r')?'\0':(char)tolower((int)aOperand[i]);
            bOperand[i] = (bOperand[i]=='\n'||bOperand[i]=='\r')?'\0':(char)tolower((int)bOperand[i]);
         }

         // Add instruction to instructionsList
         if (operands != 0) {
            instruction_t * aux = (instruction_t*) malloc(sizeof(instruction_t));
            aux->type = (operands==2) ? TYPE_TWO_OP : TYPE_ONE_OP;

            for (i=0;i<16;i++) {
               aux->function[i] = function[i];
               aux->aOperand[i] = aOperand[i];
               aux->bOperand[i] = bOperand[i];
            }

            aux->instructionNumber = instCount - 1;
            aux->lineNumber = line;
            aux->next=NULL;

            if (instructionsList==NULL) {
               instructionsList = aux;
            } else {
               instructionList_t aux2 = instructionsList;
               while (aux2->next) {
                  aux2 = aux2->next;
               }
               aux2->next = aux;
            }
         }
      }
   }

   // Code generation
   instruction_t * aux;
   aux = instructionsList;

   for (i=0;i<instCount;++i,aux=aux->next) {
      for (j=0;j<24;++j) {
         if (strcmp(aux->function,instructionName[j].name)==0) {
            break;
         }
      }

      if (instructionName[j].type!=aux->type) {
         error = 1;
         printf ("ERROR 13: Wrong operands count in function \"%s\": line %d.\n",aux->function,aux->lineNumber);
      }

      if (j==24) {
         error = 1;
         printf ("ERROR 6: Function not recognized in line %d: \"%s\".\n",aux->lineNumber,aux->function);
      } else {
         if (aux->type==TYPE_ONE_OP) {
            if (aux->aOperand[0]=='$') { // It is a label
               link_t * aux2 = linksList;
               while (aux2->next && (strcmp(aux2->name,aux->aOperand)!=0)) {
                  aux2 = aux2->next;
               }
               if (strcmp(aux2->name,aux->aOperand)==0) {
                  fprintf (outputFile,"%02x\n",(unsigned char)instructionName[j].opcode);
                  fprintf (outputFile,"%02x\n",(unsigned char)((aux2->memPos-aux->instructionNumber-1)*2));
               } else if (aux2->next==NULL) {
                  error = 1;
                  printf ("ERROR 7: Reference \"%s\" is not defined: line %d.\n",aux->aOperand,aux->lineNumber);
               }
            } else { // Not a label
               for (k=0;k<16;++k) {
                  if ((!isdigit(aux->aOperand[k])) || aux->aOperand[k]=='\0') {
                     break;
                  }
               }
               if (k==16 || aux->aOperand[k]=='\0') { // No error
                  value = (unsigned int) atoi(aux->aOperand);
                  if (value<256) {
                     fprintf (outputFile,"%02x\n",(unsigned char)instructionName[j].opcode);
                     fprintf (outputFile,"%02x\n",(unsigned char)value);
                  } else {
                     error = 1;
                     printf ("ERROR 9: Value \"%s\" is too big: line %d.\n",aux->aOperand,aux->lineNumber);
                  }
               } else { // error
                  error = 1;
                  printf ("ERROR 8: Operand \"%s\" is not a number: line %d.\n",aux->aOperand,aux->lineNumber);
               }
            }
         } else {
            if (strcmp("a",aux->aOperand)!=0) {
               error = 1;
               printf ("ERROR 10: First operand is not \"a\": line %d.\n",aux->lineNumber);
            }
            for (k=0;k<16;++k) {
               if ((!isdigit(aux->bOperand[k])) || aux->bOperand[k]=='\0') {
                  break;
               }
            }
            if (k==16 || aux->bOperand[k]=='\0') { // No error
               value = (unsigned int) atoi(aux->bOperand);
               if (value<256) {
                  fprintf (outputFile,"%02x\n",(unsigned char)instructionName[j].opcode);
                  fprintf (outputFile,"%02x\n",(unsigned char)value);
               } else {
                  error = 1;
                  printf ("ERROR 12: Value \"%s\" is too big: line %d.\n",aux->bOperand,aux->lineNumber);
               }
            } else { // Error
               error = 1;
               printf ("ERROR 11: Operand \"%s\" is not a number: line %d.\n",aux->bOperand,aux->lineNumber);
            }
         }
      }
   }

   if (instCount>128) {
      error = 1;
      printf ("ERROR 14: Code is too large. Just 128 instruccions are allowed.\n");
   } else if (instCount<128) {
      while (instCount++<127) {
         fprintf (outputFile,"00\n00\n");
      }
      fprintf (outputFile,"00\n00");
   }

   fclose (inputFile);
   fclose (outputFile);
   fclose (dumpFile);

   if (error) {
      puts ("");
      puts ("Some errors founded!!!");
      puts ("");
      puts ("");
      return 1;
   } else {
      puts ("");
      puts ("Compilation done!!!");
      puts ("");
      puts ("");
      return 0;
   }
}
