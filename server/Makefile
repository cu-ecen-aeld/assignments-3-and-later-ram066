CC ?= $(CROSS_COMPILE)gcc

CFLAGS ?= -Wall -Wextra

TARGET = aesdsocket

all: $(TARGET)

$(TARGET): aesdsocket.c
	$(CC) $(CFLAGS) aesdsocket.c -o $(TARGET)

clean:
	rm -f $(TARGET)
