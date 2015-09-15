/*
 * Copyright (c) 2015 mw. All rights reserved.
 */
#import "TxPacket.h"
#import "NSData+CRC.h"


@implementation TxPacket

#pragma mark - Object lifecycle

- (instancetype)init {
    self = [self initWithPacketType:PacketTypeQueueSHORTKeyboardReports];
    return self;
}

- (instancetype)initWithPacketType:(PacketTypes)packetType {
    self = [super init];
    if (self) {
        self.packetType = packetType;
        self.packetParam = 0;
        self.inputDataBytes = [NSMutableArray array];
        self.requiresResponse = NO;
        self.usesEncryption = NO;
    }
    return self;
}

#pragma mark - Main Packet logic

- (NSData *)getPacketWithResponse:(BOOL)requiresResponse withEncryption:(BOOL)useEncryption {
    NSUInteger fullPackageLength = self.inputDataBytes.count + 6;
    //zaokrąglamy w górę do najbliższej wartości podzielnej przez 16 oraz dzielimy wynim przez 16.   np: 14 -> 1 (16/16=1),  27 -> 2 (32/16=2)

    int lengthDiv16 = fullPackageLength / 16;
    if (lengthDiv16 * 16 < fullPackageLength) {
        lengthDiv16++;
    }
    //teraz fullPackageLength będzie całkowitym rozmiarem pakietu (CRC, payload, padding)
    fullPackageLength = (NSUInteger) (lengthDiv16 * 16);

    NSMutableData *mutableData = [NSMutableData dataWithLength:fullPackageLength + 2];
    Byte *bytesArray = mutableData.bytes;

    bytesArray[0] = 0x55;
    bytesArray[1] = (Byte) lengthDiv16;

    //jeżeli wymagana jest odpowiedź od urządzenia, ustawiamy flagę w 2gim bajcie nagłówka
    if (requiresResponse) {
        bytesArray[1] |= 0x80;
    }

    if (useEncryption) {
        bytesArray[1] |= 0x40;
        //na potem: szyfrowanie AES-128
    }

    bytesArray[6] = self.packetType;
    bytesArray[7] = self.packetParam;

    //copy payload
    for (NSUInteger i = 0; i < self.inputDataBytes.count; ++i) {
        NSNumber *number = self.inputDataBytes[i];
        bytesArray[i + 8] = (Byte) [number integerValue];
    }

    //calculate CRC
    NSUInteger crcValue = [mutableData crc32WithOffset:6
                                                length:(NSUInteger) (fullPackageLength - 4)];
    bytesArray[5] = (Byte) crcValue;
    crcValue >>= 8;
    bytesArray[4] = (Byte) crcValue;
    crcValue >>= 8;
    bytesArray[3] = (Byte) crcValue;
    crcValue >>= 8;
    bytesArray[2] = (Byte) crcValue;

    self.dataBytes = [NSData dataWithBytes:bytesArray length:fullPackageLength + 2];
    return self.dataBytes;
}

#pragma mark - Adding new data bytes

- (void)addByte:(Byte)byte {
    [self.inputDataBytes addObject:@(byte)];
    if (_dataBytes) {
        _dataBytes = nil;
    }
}

- (void)addBytes:(Byte *)bytes withLength:(NSUInteger)length {
    for (int i = 0; i < length; i++) {
        NSNumber *number = @(bytes[i]);
        [self.inputDataBytes addObject:number];
    }
    if (_dataBytes) {
        _dataBytes = nil;
    }
}

#pragma mark - Property Getter

- (NSData *)dataBytes {
    if (_dataBytes) {
        return _dataBytes;
    }
    return [self getPacketWithResponse:self.requiresResponse withEncryption:self.usesEncryption];
}

@end
