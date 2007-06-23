//
//  SSPuginsSecondClassProtocol.h
//  StructServer
//
//  Created by Julian on 12/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSObject (SSPluginsSecondClassProtocol)

// REQUERIDO
// Debe devolver un diccionario con dos miembros, el primero indicando que se hizo
// y el segundo con lo que se le debe enviar al cliente. Las respectivas claves
// deben ser: "Log" y "Message".
- (NSDictionary *)performCommand:(NSString *)command;
@end
