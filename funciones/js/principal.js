/********************************
******  VARIABLES GLOBALES ******
********************************/

var semana = 0;

/*******************************/

function fInicializarContenido()
{
    var inicio = '<div id="divSubContenido1"></div>';
    inicio += '<div id="divSubContenido2"></div>';
    document.getElementById('divContenido').innerHTML = inicio;
}

function fCambioClase(clase)
{
    var objetivo = document.getElementById('divContenido');
    objetivo.className = clase;
}

function fCargaCompras()
{
    fInicializarContenido();
    fCambioClase('compras');
}

function fCargaViajes()
{
    fInicializarContenido();
    fCambioClase('viajes');
}

function fCargaVacaciones()
{
    fInicializarContenido();
    fCambioClase('vacaciones');
}

function fCargaAnticipos()
{
    fInicializarContenido();
    fCambioClase('anticipos');
}

function fCargaReservas()
{
    fInicializarContenido();
    fCambioClase('reservas');
    fInputsReservas();
    fTablaReservas();
}

function fCargaSolicitudes()
{
    fInicializarContenido();
    fCambioClase('solicitudes');
    fConsultarSolicitudes();
}

/**********************************************
******  FUNCIONES DEL APARTADO RESERVAS  ******
**********************************************/

    //Inicio de las funciones de construcción de la consulta y realización de reservas

function fInputsReservas()
{
    semana = 0;
    var destino = document.getElementById('divSubContenido1');

    destino.insertAdjacentHTML('beforeend','<h2>Consulta de la Reserva</h2>');
    destino.insertAdjacentHTML('beforeend','<select id="cboEquipos"></select>');
    fPedirListaEquipos();

    destino.insertAdjacentHTML('beforeend','<h2>Realizar Reserva</h2>');
    destino.insertAdjacentHTML('beforeend','<p>Fechas</p>');

    destino.insertAdjacentHTML('beforeend','<label for="fechaInicio">Inicial:</label>');
    destino.insertAdjacentHTML('beforeend','<input type="date" id="fechaInicio" />');
    document.getElementById('fechaInicio').addEventListener('change',fFechaMin,false);
    document.getElementById('fechaInicio').disabled = true;

    destino.insertAdjacentHTML('beforeend','<label for="fechaFin">Final:</label>');
    destino.insertAdjacentHTML('beforeend','<input type="date" id="fechaFin" />');
    document.getElementById('fechaFin').disabled = true;

    destino.insertAdjacentHTML('beforeend','<p>Horas</p>');

    destino.insertAdjacentHTML('beforeend','<label for="cboHoraInicio">Inicial:</label>');
    destino.insertAdjacentHTML('beforeend','<select id="cboHoraInicio"></select>');
    fLlenarHoras('cboHoraInicio');
    document.getElementById('cboHoraInicio').disabled = true;

    destino.insertAdjacentHTML('beforeend','<label for="cboHoraFin">Final:</label>');
    destino.insertAdjacentHTML('beforeend','<select id="cboHoraFin"></select><br /><br />');
    fLlenarHoras('cboHoraFin');
    document.getElementById('cboHoraFin').disabled = true;

    destino.insertAdjacentHTML('beforeend','<input type="button" id="btReserva" value="Reservar">');
    document.getElementById('btReserva').addEventListener('click',fRealizarReserva,false);
    document.getElementById('btReserva').disabled = true;

    destino.insertAdjacentHTML('beforeend','<div id="divMsgReserva"></div>');
}

function fFechaMin()
{
    var min = document.getElementById('fechaInicio').value;

    document.getElementById('fechaFin').setAttribute('min',min);
    document.getElementById('fechaFin').value = min;
}

function fLlenarHoras(id)
{
    var destino = document.getElementById(id);
    var horaInicial = 8;
    var bloquesHorarios = 18;
    var option = '<option value="" style="display:none" selected="selected" >Seleccionar Hora</option>';

    destino.insertAdjacentHTML('beforeend',option);
    for(h=0; h<=bloquesHorarios; h++)
    {
        if(h%2 == 0)
        {
            option = '<option value="' + horaInicial + ':00">' + horaInicial + ':00</option>';
            destino.insertAdjacentHTML('beforeend',option);
        }
        else
        {
            option = '<option value="' + horaInicial + ':30">' + horaInicial + ':30</option>';
            destino.insertAdjacentHTML('beforeend',option);
            horaInicial++
        }
    }
}

    //Inicio de las funciones de construccion de la tabla de Reservas y su contenido

function fTablaReservas()
{
    //Selector del elemento dentro del cual se crea la tabla
    var destino = document.getElementById('divSubContenido2');

    destino.innerHTML = '';
    destino.insertAdjacentHTML('beforeend','<h2>Estado de la Reserva</h2>');
    destino.insertAdjacentHTML('beforeend','<div id="divTabla"><table id="tblSemana"></table></div>');

    var dias = ['Lunes','Martes','Miercoles','Jueves','Viernes'];
    var tabla = '';

    //Construccion de la cabecera de la tabla

    var horaInicial = 8;
    var horaFinal = 17;
    var cabecera = '<tr><th></th>';

    for(h=0; h<=horaFinal; h++)
    {
        if(h%2 == 0)
        {
            cabecera += '<th>' + horaInicial + ':00</th>';
        }
        else
        {
            cabecera += '<th>' + horaInicial + ':30</th>';
            horaInicial++
        }
    }
    cabecera += '</tr>';
    tabla += cabecera;

    //Construccion del cuerpo de la tabla

    var fila = '';

    for(d=0; d<5; d++)
    {
        horaInicial = 8;
        fecha = fFechasSemana(d,semana);
        fila = '<tr id="' + fecha + '"><th><p>' + dias[d] + '</p><p>' + fecha + '</p></th>';
        for(h=0; h<18; h++)
        {
            if(h%2 == 0)
            {
                fila += '<td id="' + horaInicial + ':00:00"></td>';
            }
            else
            {
                fila += '<td id="' + horaInicial + ':30:00"></td>';
                horaInicial++
            }
        }
        fila += '</tr>';
        tabla += fila;
    }
    document.getElementById('tblSemana').insertAdjacentHTML('beforeend',tabla);
    fBotonesSemana();
}

function fBotonesSemana()
{
    var destino = document.getElementById('divSubContenido2');

    destino.insertAdjacentHTML('beforeend','<input type="button" id="btSemanaAnterior" value="Anterior">');
    document.getElementById('btSemanaAnterior').addEventListener('click',fSemAnterior,false);

    destino.insertAdjacentHTML('beforeend','<input type="button" id="btSemanaActual" value="Actual">');
    document.getElementById('btSemanaActual').addEventListener('click',fSemActual,false);

    destino.insertAdjacentHTML('beforeend','<input type="button" id="btSemanaSiguiente" value="Siguiente">');
    document.getElementById('btSemanaSiguiente').addEventListener('click',fSemSiguiente,false);

    fEstadoBotones();
}

function fFechasSemana(d,s)
{
    var hoy = new Date;

    //Este if es necesario ya que para JS el Domingo es el primer dia de la semana
    if(hoy.getDay() !=0)
    {
        h = hoy.getDate() - hoy.getDay() + ((1 + d) + (s * 7));
    }
    else
    {
        h = hoy.getDate() - hoy.getDay() + ((1 + d) + ((s-1) * 7));
    }
    //Suponiendo d=0 y s=0, h será la fecha correspondiente al Lunes de la semana actual
    fecha = new Date(hoy.setDate(h)).toISOString().split('T')[0];

    return fecha;
}

    //Fin de las funciones de construccion
    //Inicio de las funciones de funcionalidad de Reservas

    /**********************************************
    ******  INICIO CONSULTA DE LAS RESERVAS  ******
    **********************************************/

function fPedirListaEquipos()
{
    conexion = new XMLHttpRequest();
    conexion.onreadystatechange = fLlenarEquipos;
    conexion.open('POST','../ajax/cargaEquipos.php',true);
    conexion.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    conexion.send();
}

function fLlenarEquipos()
{
    if(conexion.readyState == 4 && conexion.status == 200)
    {
        var cbo = document.getElementById('cboEquipos');
        var contenidoCbo = '';
        var tipo = '';

        cbo.innerHTML = '<option value="" style="display:none" selected="selected" >Seleccionar Equipamiento</option>';
        JSON.parse(conexion.responseText,function(cod,ristra){
            if(cod != "")
            {
                var info = ristra.split("|");
                if(tipo == '')
                {
                    contenidoCbo += '<optgroup label="' + info[1] + '">';
                    tipo = info[1];
                }
                else if(tipo != info[1])
                {
                    contenidoCbo += '</optgroup><optgroup label="' + info[1] + '">';
                    tipo = info[1];
                }
                contenidoCbo += '<option value="' + cod + '" >' + info[0] + '</option>';
            }
        });
        contenidoCbo += '</optgroup>';
        cbo.insertAdjacentHTML('beforeend',contenidoCbo);
        cbo.addEventListener('change',fConsultarReservas,false);
    }
}

function fConsultarReservas()
{
    document.getElementById('fechaInicio').disabled = false;
    document.getElementById('fechaFin').disabled = false;
    document.getElementById('cboHoraInicio').disabled = false;
    document.getElementById('cboHoraFin').disabled = false;
    document.getElementById('btReserva').disabled = false;

    conexion = new XMLHttpRequest();
    conexion.onreadystatechange = fResultadoConsultaReservas;
    conexion.open('POST','../ajax/consultarReservas.php',true);
    conexion.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    conexion.send(fPrepararConsultaReservas());
}

function fPrepararConsultaReservas()
{
    var equipo = document.getElementById('cboEquipos').value;

    var post = 'equipo=' + equipo;
    post += '&semana=' + semana;

    return post;
}

function fResultadoConsultaReservas()
{
    if(conexion.readyState == 4 && conexion.status == 200)
    {		
		fTablaReservas();
        fEstadoBotones();
        var salida = document.getElementById('divMsgReserva');
        var tabla = document.getElementById('tblSemana');
        var filas = tabla.getElementsByTagName('tr');

        JSON.parse(conexion.responseText,function(cod,ristra){
            if(cod != "")
			{
                if(cod == 'vacio')
                {
                    salida.innerHTML = '<h3>' + ristra + '</h3>';
                }
                else
                {
                    salida.innerHTML = '';
                    
                    var datosReserva = ristra.split("|");
                    var color = fRndColor();
                    var fechasReserva = [];
                    fechasReserva.push(new Date(datosReserva[1] + ' ' + datosReserva[3])); 
                    fechasReserva.push(new Date(datosReserva[2] + ' ' + datosReserva[4]));
                    
                    for(numFila = 1; numFila <= (filas.length - 1); numFila++)
                    {
                        columnas = filas[numFila].getElementsByTagName('td');
                        
                        for(celda = 0; celda < columnas.length; celda++)
                        {
                            fechaHoraCelda = new Date(filas[numFila].id + ' ' + columnas[celda].id);

                            if(fechasReserva[0] <= fechaHoraCelda && fechaHoraCelda < fechasReserva[1])
                            {
                                columnas[celda].style.background = color;
                            }
                        }
                    }
                }
			}
		});
	}
}

function fRndColor()
{
    var color = Math.floor(Math.random() * 16777216).toString(16);
    return '#000000'.slice(0, -color.length) + color;
}

    /**************************************************
    ******  INICIO NAVEGACION TABLA DE RESERVAS  ******
    **************************************************/

function fSemAnterior()
{
    semana--;
    fConsultarReservas();
}

function fSemActual()
{
    semana = 0;
    fConsultarReservas();
}

function fSemSiguiente()
{
    semana++;
    fConsultarReservas();
}

function fEstadoBotones()
{
    var anterior = document.getElementById('btSemanaAnterior');
    var actual = document.getElementById('btSemanaActual');
    var siguiente = document.getElementById('btSemanaSiguiente');
    var cboEquipo = document.getElementById('cboEquipos').value;

    if(cboEquipo == '')
    {
        anterior.disabled = true;
        actual.disabled = true;
        siguiente.disabled = true;
    }
    else if(semana == 0)
    {
        anterior.disabled = false;
        actual.disabled = true;
        siguiente.disabled = false;
    }
    else if(semana <= -4)
    {
        anterior.disabled = true;
        actual.disabled = false;
        siguiente.disabled = false;
    }
    else if(semana >= 4)
    {
        anterior.disabled = false;
        actual.disabled = false;
        siguiente.disabled = true;
    }
    else
    {
        anterior.disabled = false;
        actual.disabled = false;
        siguiente.disabled = false;
    }
}

    /********************************************
    ******  INICIO REALIZAR RESERVA NUEVA  ******
    ********************************************/

function fRealizarReserva()
{
    var fechaInicio = document.getElementById('fechaInicio').value;
    var fechaFin = document.getElementById('fechaFin').value;
    var horaInicio = document.getElementById('cboHoraInicio').value;
    var horaFin = document.getElementById('cboHoraFin').value;
    
    if(fechaInicio == '' || fechaFin == '' || horaInicio == '' || horaFin == '')
    {
        destino = document.getElementById('divMsgReserva');
        destino.innerHTML = '<h3>Todos los campos son obligatorios</h3>';
        setTimeout(function(){destino.innerHTML = '';},2000);
    }
    else
    {
        conexion = new XMLHttpRequest();
        conexion.onreadystatechange = fResultadoReserva;
        conexion.open('POST','../ajax/realizarReserva.php',true);
        conexion.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        conexion.send(fPrepararDatosReserva());
    }
}

function fPrepararDatosReserva()
{
    var equipo = document.getElementById('cboEquipos').value;
    var fechaInicio = document.getElementById('fechaInicio').value;
    var fechaFin = document.getElementById('fechaFin').value;
    var horaInicio = document.getElementById('cboHoraInicio').value;
    var horaFin = document.getElementById('cboHoraFin').value;
    
    var post = 'equipo=' + equipo;
    post += '&fechaInicio=' + fechaInicio;
    post += '&fechaFin=' + fechaFin;
    post += '&horaInicio=' + horaInicio;
    post += '&horaFin=' + horaFin;
    
    return post;
}

function fResultadoReserva()
{
    if(conexion.readyState == 4 && conexion.status == 200)
    {		
		destino = document.getElementById('divMsgReserva');
        JSON.parse(conexion.responseText,function(cod,salida){
			if(cod != "")
			{
                switch(salida)
                {
                    case '0':
                        fConsultarReservas();
                        destino.innerHTML = '<h3>Reserva realizada con éxito</h3>';
                        break;
                    case '-1':
                        destino.innerHTML = '<h3>El equipo seleccionado no es válido</h3>';
                        break;
                    case '-2':
                        destino.innerHTML = '<h3>El rango de fechas elegido no es válido</h3>';
                        break;
                    case '-3':
                        destino.innerHTML = '<h3>El rango de horas elegido no es válido</h3>';
                        break;
                    case '-4':
                        destino.innerHTML = '<h3>No estamos en el ministerio de la verdad</h3>';
                        break;
                    case '-5':
                        destino.innerHTML = '<h3>Existe una reserva previa</h3>';
                        break;
                }
			}
		});
	}
    setTimeout(function(){destino.innerHTML = '';},2000);
}

/******  FINAL APARTADO RESERVAS  ******/

/*************************************************
******  FUNCIONES DEL APARTADO SOLICITUDES  ******
*************************************************/

    //Inicio de las funciones de construcción de la consulta y procesado de solicitudes

function fConsultarSolicitudes()
{
    conexion = new XMLHttpRequest();
    conexion.onreadystatechange = fTablaSolicitudes;
    conexion.open('POST','../ajax/consultarSolicitudes.php',true);
    conexion.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    conexion.send();
}

function fTablaSolicitudes()
{
    if(conexion.readyState == 4 && conexion.status == 200)
    {		
		var destino = document.getElementById('divSubContenido1');
        var tabla = '';

        destino.innerHTML = '';
        destino.insertAdjacentHTML('beforeend','<h2>Solicitudes Pendientes</h2>');
        destino.insertAdjacentHTML('beforeend','<div id="divTabla"><table id=tblSolicitudes></table></div>');

        JSON.parse(conexion.responseText,function(cod,ristra){
			if(cod != "")
			{
                if(cod != 'vacio')
                {
                    var info = ristra.split("|");

                    tabla += '<tr>';
                    tabla += '<td>' + info[0] + '</td>';
                    tabla += '<td>' + info[1] + '</td>';
                    tabla += '<td>' + info[2] + '</td>';
                    tabla += '<td>' + info[3] + '</td>';
                    tabla += '<td><button id="btnAprobar" value="1" onclick="fProcesarSolicitud(' + cod + ',this.value)" >Aprobar</button>';
                    tabla += '<button id="btnAprobar" value="-1" onclick="fProcesarSolicitud(' + cod + ',this.value)" >Denegar</button></td>'
                    tabla += '</tr>';
                }
                else
                {
                    destino.insertAdjacentHTML('beforeend','<h3>' + ristra + '</h3>');
                }
			}
		});
        document.getElementById('tblSolicitudes').insertAdjacentHTML('beforeend',tabla);
	}
}

function fProcesarSolicitud(id,decision)
{
    conexion = new XMLHttpRequest();
    conexion.onreadystatechange = fRespuestaSolicitud;
    conexion.open('POST','../ajax/procesarSolicitud.php',true);
    conexion.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    conexion.send(fPrepararDatosSolicidud(id,decision));
}

function fPrepararDatosSolicidud(id,decision)
{
    var post = 'idReserva=' + id;
    post += '&decision=' + decision;

    return post;
}

function fRespuestaSolicitud()
{
    if(conexion.readyState == 4 && conexion.status == 200)
    {
        destino = document.getElementById('divSubContenido2');

        JSON.parse(conexion.responseText,function(cod,salida){
			if(cod != "")
			{
                if(cod != 'error')
                {
                    destino.insertAdjacentHTML('beforeend','<h3>La solicitud ' + salida + ' ha sido procesada correctamente.</h3>');
                    fConsultarSolicitudes();
                }
                else
                {
                    destino.insertAdjacentHTML('beforeend','<h3>Hubo un error al intentar procesar la solicitud ' + salida + '.</h3>');
                }
			}
		});
	}
}

/******  FINAL APARTADO SOLICITUDES  ******/