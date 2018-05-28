
INSERT INTO public.genero(nombre)
    VALUES 
    ('Masculino'),
    ('Femenino');

INSERT INTO public.rango_edad(nombre, minimo, maximo)
    VALUES 
    ('Bebe', 			0, 1),
    ('Niño/a', 			1, 12),
    ('Joven', 			12, 30),
    ('Adulto', 			30, 60),
    ('Adulto mayor', 	60, 120);


INSERT INTO public.funcionalidad(nombre, icono, orden, nivel, estatus, url_vista)
    VALUES 
    ( 'Dashboard'			,	'fa fa-leaf'		,	1,	1,	1	,'dashboard.html'		);

INSERT INTO public.funcionalidad(nombre, icono, orden, nivel, estatus)
    VALUES 
    ( 'Registros Básicos'		,	'fa fa-edit'		,	2,	1,	1),
    ( 'Configuración'			,	'fa fa-cogs'		,	3,	1,	1),
    ( 'Visitas'				,	'fa fa-calendar'	,	4,	1,	1),
    ( 'Ofertas y promociones'		,	'fa fa-tags'		,	5,	1,	1),			
    ( 'Reportes'			,	'fa fa-bar-chart-o'	,	6,	1,	1),
    ( 'Administración del Sistema'	,	'fa fa-wrench'		,	7,	1,	1);

INSERT INTO public.funcionalidad(id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista)
    VALUES 
    (2,	'Unidades'				,	'fa fa-chevron-right'	,	1,	2,	1	,'regi_unidad.html'		),
    (2,	'Tipos de Parámetros'	,	'fa fa-chevron-right'	,	2,	2,	1	,'regi_tipo_parametro.html'	),
    (2,	'Tipos de Contacto'		,	'fa fa-chevron-right'	,	3,	2,	1	,'regi_tipo_contacto.html'	);


INSERT INTO public.funcionalidad(id_funcionalidad_padre, nombre, icono, orden, nivel, estatus)
    VALUES 
    (2,	'Planes'				,	'fa fa-chevron-right'	,	4,	2,	1);


INSERT INTO public.funcionalidad(id_funcionalidad_padre, nombre, orden, nivel, estatus, url_vista)
	VALUES
    (11,'Alimentos'				,	1,	3,	1	,'regi_alimentos.html'		),
    (11,'Comidas'				,	2,	3,	1	,'regi_comidas.html'		),
    (11,'Suplementos'			,	3,	3,	1	,'regi_suplementos.html'	),
    (11,'Ejercicios'			,	4,	3,	1	,'regi_ejercicios.html'		),
    (11,'Tipos de Dieta'		,	5,	3,	1	,'regi_tipo_dieta.html'		);


INSERT INTO public.funcionalidad(id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista)
    VALUES 
    (2,	'Horario'				,	'fa fa-chevron-right'	,	5,	2,	1	,'regi_horario.html'		),
    (2,	'Condiciones de Garantía'	,	'fa fa-chevron-right'	,	6,	2,	1	,'regi_condiciones_garantia.html'),
    (2,	'Tipos de Valoración'	,	'fa fa-chevron-right'	,	7,	2,	1	,'regi_tipo_valoracion.html'	),
    (2,	'Especialidades'		,	'fa fa-chevron-right'	,	8,	2,	1	,'regi_especialidad.html'	),
    (3,	'Parámetros'			,	'fa fa-chevron-right'	,	1,	2,	1	,'conf_parametros.html'		);


INSERT INTO public.funcionalidad(id_funcionalidad_padre, nombre, icono, orden, nivel, estatus)
    VALUES     
    (3,	'Sistema'				,	'fa fa-chevron-right'	,	2,	2,	1);
    

INSERT INTO public.funcionalidad(id_funcionalidad_padre, nombre, orden, nivel, estatus, url_vista)
    VALUES     
    (22,'Motivos y Respuestas'	,	1,	3,	1	,'conf_sist_mensajes.html'	),
    (22,'Notificaciones'		,	2,	3,	1	,'conf_sist_notificacion.html'	),
    (22,'Agenda'				,	3,	3,	1	,'conf_agenda.html'		),
    (22,'Criterios de Valoración',	4,	3,	1	,'conf_sist_valoracion.html'	),
    (22,'Filtros'				,	5,	3,	1	,'conf_sist_filtros.html'	);

INSERT INTO public.funcionalidad(id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista)
    VALUES 
    (3,	'Servicios'				,	'fa fa-chevron-right'	,	3,	2,	1	,'conf_servicios.html'		);

INSERT INTO public.funcionalidad(id_funcionalidad_padre, nombre, icono, orden, nivel, estatus)
    VALUES 
    (3,	'Planes'				,	'fa fa-chevron-right'	,	4,	2,	1);

INSERT INTO public.funcionalidad(id_funcionalidad_padre, nombre, orden, nivel, estatus, url_vista)
    VALUES 
    (29,'Dietas'				,	1,	3,	1	,'conf_plan_dieta.html'		),
    (29,'Plan de Suplemento'	,	2,	3,	1	,'conf_plan_suplemento.html'	),
    (29,'Planes de Entrenamiento',	3,	3,	1	,'conf_plan_actividad.html'	);

INSERT INTO public.funcionalidad(id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista)
    VALUES     
    (4,	'Atender'				,	'fa fa-chevron-right'	,	1,	2,	1	,'visitas.html'			);


INSERT INTO public.dia_laborable (dia)
    VALUES
	('Domingo'),
	('Lunes'),
	('Martes'),
	('Miercoles'),
	('Jueves'),
	('Viernes'),
	('Sábado');

SELECT setval('public.id_tipo_motivo_seq', 1, false);
INSERT INTO public.tipo_motivo (nombre, canal_escucha)
VALUES
	('Solicitud', 'f'),
	('Reclamo', 'f'),
	('Incidencia', 'f'),
	('Queja', 't'),
	('Sugerencia', 't'),
	('Pregunta', 't'),
	('Otro', 't'),
	('Opinión', 't');


INSERT INTO public.estado_solicitud(id_estado_solicitud,tipo, nombre)
    VALUES 
(1,1,	'Aprobado'),
(2,2,	'Rechazado por horario del empleado ocupado'),
(3,2,	'Rechazado por horario no laborable del empleado'),
(4,2,	'Rechazado por no aceptación del precio');

INSERT INTO public.tiempo (nombre, abreviatura)
VALUES
('minutos','min'),  
('horas','hrs'),    
('dias','ds'),
('meses','mes');