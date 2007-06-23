//
//  ConectionManager.h
//  StructServer
//
//  Created by Julian on 5/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"


@interface Controller (ConectionManager)

- (int)validatePort:(int)port;
- (void)startServerUsingPort:(int)port;
- (void)stopServer;
- (void)stopServerInternals;

// Actualiza el la hora de inicio de actividad
- (void)setServerStartedDate;

// Actualiza el tiempo de actividad en la interfaz
- (void)showActiveTime;

// 
// Metodos para manejar la lista de conexiones
//
/* Inicializa la tabla con algunas propiedades */
- (void)initConnectionsTable;

/* Activa el boton "Terminar si hay alguna fila seleccionada */
- (void)toogleFinishButton:(id)sender;

/* Actualiza los datos de la Lista */
- (void)reloadConnectionsData;

	/* Actualizacion para modificar el tiempo transcurrido */
- (void)updateTableAndActiveTime:(NSTimer *)timer;

/* Actualiza el numero de conexiones */
- (void)updateConnectionsCount:(int)count;

/* Selecciona todas las filas de la lista */
- (IBAction)selectAllConnections:(id)sender;

/* Finaliza las conexiones seleccionadas */
- (IBAction)finishSelectedConnections:(id)sender;;

/* Hace visibles todas las columnas de la Lista */
- (void)resizeColumnsOfTable:(NSTableView *)aTableView;
@end
