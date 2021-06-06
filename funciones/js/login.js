$(document).ready(function()
{
    addEventListener('load',inicializarEventos,false);

    function inicializarEventos()
    {
        var obj = document.getElementById('btnSubmit')
        obj.addEventListener('click',fCheckCredentials,false);
    }

    function fCheckCredentials()
    {
        conexion = new XMLHttpRequest();
        conexion.onreadystatechange = fProcesarDatos;
        conexion.open('POST','ajax/ldap.php',true);
        conexion.setRequestHeader('Content-type','application/x-www-form-urlencoded');
        conexion.send(fPrepPost());
    }

    function fPrepPost()
    {
        var usu = document.getElementById('txtUsuario').value;
        var pass = document.getElementById('txtPass').value;
        usu = 'usuario=' + usu;
        pass = 'pass=' + pass;
        post = usu + '&' + pass;
        return post;
    }
    
    function fProcesarDatos()
    {
        if(conexion.readyState == 4 && conexion.status == 200)
        {
            JSON.parse(conexion.responseText,function(cod,data)
            {
                if(cod != '')
                {
                    if(cod != 'error')
                    {
                        var user = document.getElementById('txtUsuario').value;
                        data = data.split('|');
                        var userFull = data[0];
                        var fullName = data[1];
                        var isAdmin = data[2];
                        var url = 'php/session.php?usuario=' + user + '&usuarioComp=' + userFull + '&nomComp=' + fullName + '&isAdmin=' + isAdmin;
                        window.location.href = url;
                    }
                    else
                    {
                        fError(data);
                    }
                }
            });
        }
    }

    function fError(i)
    {
        $('#pError' + i).css('display','');
        $('#pError' + i).fadeOut(3500);
    }
    
});