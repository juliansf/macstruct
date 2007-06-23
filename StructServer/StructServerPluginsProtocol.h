/*
 *  StructServerPluginsProtocol.h
 *  StructServer
 *
 *  Created by Julian on 5/9/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

@interface NSObject (StructServerPluginsProtocol)

// REQUERIDO
// Devuelve la vista principal del servidor de estructuras, en la misma
// deberan ir las configuraciones de la estructura de datos 
// implementada por el plugin
- (NSView *)mainView;

// OPCIONAL
// Devuelve la vista de usuarios. En la misma debera ir la interfaz de
// configuracion de usuarios.
// Si este metodo no es implementado, no se mostrara el icono "Usuarios" 
// en la toolbar 
- (NSView *)usersView;

// REQUERIDO
// Devuelve la vista de estadisticas, en la cual se deberan mostrar las 
// estadisticas de uso del servidor.
- (NSView *)statisticsView;

// REQUERIDO
// Debe crear un manejador de una instancia de la estructura que 
// provee el plugin.
- (void)newStructureManager;

@end
