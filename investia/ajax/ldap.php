<?php

require '../funciones/php/ckGroup.php';
if(isset($_POST))
{
    if(empty($_POST['usuario']) || empty($_POST['pass']))
    {
        echo '{"error":-1}'; //Código de error si falta una o ambas credenciales
    }
    else
    {
        $user = strtolower($_POST['usuario']);
        $pass = $_POST['pass'];

        //IP del servidor AD
        $adServer = 'ldap://192.168.234.128';
        
        //Conexión al servidor AD
        $ldap = ldap_connect($adServer);
        //ldap_set_option($ldap, LDAP_OPT_PROTOCOL_VERSION, 3);

        if($ldap)
        {
            $ldaprdn = 'intranet\\' . $user;
            
            //Autenticación
            $bind = @ldap_bind($ldap,$ldaprdn,$pass);
            
            if($bind)
            {
                $data = array();
                $filter = "(sAMAccountName=$user)";
                
                /*Limitar el rango de búsqueda reduce el tiempo de respuesta del servidor y mejora
                significativamente el tiempo de login. Esta comprobación se hace solo para incluir al
                usuario administrador en la búsqueda manteniendo un tiempo de respuesta mínimo*/
                if(ckadmin($user))
                {
                    $tree = 'CN=Users,DC=intranet,DC=investia,DC=es';
                    $search = ldap_search($ldap,$tree,$filter);        
                    $entries = ldap_get_entries($ldap,$search);

                    $fullname = $entries['0']['cn']['0'];

                    $data[1] = 'administrador@investia.es|' . $fullname . '|1';
                }
                else
                {                    
                    $tree = 'OU=intranet,DC=intranet,DC=investia,DC=es';
                    $search = ldap_search($ldap,$tree,$filter);        
                    $entries = ldap_get_entries($ldap,$search);
                    ckDomAdmin($entries['0']['memberof']) == true ? $isAdmin = '1' : $isAdmin = '0';
                    if($isAdmin == 0)
                    {
                        ckDepDir($entries['0']['memberof']) == true ? $isAdmin = '2' : $isAdmin = '0';
                    }

                    $fullname = $entries['0']['cn']['0'];
                    $account = $entries['0']['userprincipalname']['0'];

                    $data[1] = $account . '|' . $fullname . '|' . $isAdmin;
                }

                ldap_unbind($ldap);

                //print('<pre>' . print_r($entries,true) . '</pre>');

                echo(json_encode($data));
            }

            else
            {
                echo '{"error":-3}'; //Código de error si las credenciales son incorrectas
            }
        }
        else
        {
            echo '{"error":-2}'; //Código de error si falla la conexión al servidor
        }
    }
}

?>