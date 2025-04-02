------------------------------------------
--  BC4.1. Identidades                  --
------------------------------------------
--   autor:          David L.T          --
--   FP:             1º DAM             --
--   Versión         1.0.0              --
--   Asignatura:     Bases de Datos     --
------------------------------------------

DROP TABLE PERSONA CASCADE CONSTRAINTS;
CREATE TABLE PERSONA (
    id          NUMBER NOT NULL PRIMARY KEY,
    nombre      VARCHAR(255),
    apellidos   VARCHAR(255),
    edad        NUMBER,
    municipio   VARCHAR(255),
    provincia   VARCHAR(255)
);

-- Cambiar la ruta "C:\app\desmon0xff\product\21c\data" con
-- el usuario que usted tenga, el campo desmon0xff debera ser el nombre de 
-- usuario que usted tenga. Ademas debera dirijirse a este directorio y crear 
-- la carpeta 'data' o ejecutar la secuencia de la parte inferior para que la
-- cree por primera vez. Aqui debera copiar los CSV's con los datos indicados,
-- estando los campos en el mismo orden que se indica en los CREATE TABLE
-- y debera tener los mismos nombres los CSV que lo que se indica abajo para
-- que se han cargados.
CREATE OR REPLACE DIRECTORY dir_read as 'C:\app\desmon0xff\product\21c\data';
GRANT ALL ON DIRECTORY dir_read TO PUBLIC;

-- Mostrar todos los directorios existentes para verificar que el directorio fue
-- creado correctamentew
SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM DBA_DIRECTORIES;


DROP TABLE PROVINCIA CASCADE CONSTRAINTS;
CREATE TABLE PROVINCIA (  
	codPro NUMBER,  
	nombre VARCHAR2(96)
) ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY DIR_READ
	ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        LOGFILE 'PRUEBA_EXT.log'
        BADFILE 'PRUEBA_EXT.bad'
        DISCARDFILE 'PRUEBA_EXT.dsc'
        FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' LRTRIM(
            codPro CHAR,
            nombre CHAR
        )
    ) LOCATION (DIR_READ:'CA-provincia.csv')

) REJECT LIMIT 5000;

DROP TABLE MUNICIPIO CASCADE CONSTRAINTS;
CREATE TABLE MUNICIPIO (  
	codPro NUMBER,  
    codMum NUMBER,  
	nombre VARCHAR2(128)
) ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY DIR_READ
	ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        LOGFILE 'PRUEBA_EXT.log'
        BADFILE 'PRUEBA_EXT.bad'
        DISCARDFILE 'PRUEBA_EXT.dsc'
        FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' LRTRIM(
            codPro CHAR,
            codMum CHAR,
            nombre CHAR
        )
    ) LOCATION (DIR_READ:'CA-municipio.csv')

) REJECT LIMIT 5000;

DROP TABLE NOMBRES_FREC CASCADE CONSTRAINTS;
CREATE TABLE NOMBRES_FREC (  
	orden NUMBER,
	nombre VARCHAR2(64)
) ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY DIR_READ
	ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        LOGFILE 'PRUEBA_EXT.log'
        BADFILE 'PRUEBA_EXT.bad'
        DISCARDFILE 'PRUEBA_EXT.dsc'
        FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' LRTRIM(
            orden CHAR,
            nombre CHAR
        )
    ) LOCATION (DIR_READ:'nombres_por_edad_media.csv')

) REJECT LIMIT 5000;


DROP TABLE APELLIDOS_FREC CASCADE CONSTRAINTS;
CREATE TABLE APELLIDOS_FREC (   
	orden NUMBER,
	appelido VARCHAR2(64)
) ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY DIR_READ
	ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        LOGFILE 'PRUEBA_EXT.log'
        BADFILE 'PRUEBA_EXT.bad'
        DISCARDFILE 'PRUEBA_EXT.dsc'
        FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' LRTRIM(
            orden CHAR,
            appelido CHAR
        )
    ) LOCATION (DIR_READ:'apellidos_mas_frecuentes.csv')

) REJECT LIMIT 5000;


CREATE SEQUENCE secuencia_id_persona 
    START WITH 1 
    INCREMENT BY 1 
    MINVALUE 1 
    NOCYCLE 
    CACHE 20;

DECLARE
    -- bool status = false;
    -- bool existe_o_no_secuencia = false;
    vStatus NUMBER := 0;
    vIdentidadActual NUMBER := 0;
    vNIdentidades NUMBER := &Cantidad_de_identidades;
    vSql VARCHAR2(300);

    ----------------------------------------------------------------------------
    --                                Registros                               --
    ----------------------------------------------------------------------------

    -- registro para generar ID's aleatorios que luego seran resueltos para generar
    -- la identidad final
    TYPE rIdsRandom IS RECORD (
        mNombre     NOMBRES_FREC.ORDEN%TYPE,
        mCodPro     PROVINCIA.CODPRO%TYPE,
        mCodMum     MUNICIPIO.CODMUM%TYPE,
        mApellido1  APELLIDOS_FREC.ORDEN%TYPE,
        mApellido2  APELLIDOS_FREC.ORDEN%TYPE
    );
    vIdsRandom rIdsRandom;

    -- registro con variables para cada identidad generada
    TYPE rIdentidad IS RECORD (
        mId         PERSONA.ID%TYPE,
        mNombre     PERSONA.NOMBRE%TYPE,
        mApellidos  PERSONA.APELLIDOS%TYPE,
        mEdad       PERSONA.EDAD%TYPE,
        mMunicipio  PERSONA.MUNICIPIO%TYPE,
        mProvincia  PERSONA.PROVINCIA%TYPE         
    );
    vIdentidad rIdentidad;

    ----------------------------------------------------------------------------
    --                                Funciones                               --
    ----------------------------------------------------------------------------

    FUNCTION GenerarIDsDeIdentidadRandom RETURN rIdsRandom IS
        /*
         * Esta funcion tiene el proposito de generar una identidad aleatoria,
         * generando ID's aleatorios de campos con datos validos para luego 
         * resolverlos
         */

        vIdsRandom rIdsRandom;  -- Declaración de las variables en la funcion

        -- variable para almacenar la cantidad de filas que tiene una tabla
        vCountRow NUMBER := 0;
        vTEMP NUMBER := 0; -- variable temporal
    BEGIN
        -- generar ID random para el nombre de la identidad
        select count(*) into vCountRow from NOMBRES_FREC;
        vIdsRandom.mNombre := ROUND(DBMS_RANDOM.VALUE(LOW=> 1, HIGH=> vCountRow));

        -- generar ID random para la provincia de la identidad
        select count(*) into vCountRow from PROVINCIA;
        vTEMP := ROUND(DBMS_RANDOM.VALUE(LOW=> 1, HIGH=> vCountRow));
        -- se selecciona el numero de pronvincia aleatoriamente a traves de 
        -- un numero de fila generado aleatoriamente
        SELECT codPRO INTO vIdsRandom.mCodPro
        FROM (
            -- crear una tabla temporal con codigos de provincias y el numero de fila en la que estan:
            SELECT codPRO, ROWNUM AS rn
            FROM PROVINCIA
        )
        WHERE rn = vTEMP;

        -- calcular municipio aleatorio
        -- generar ID random para los municipios de la provincia de la identidad
        select count(*) into vCountRow from MUNICIPIO 
            where codPro = vIdsRandom.mCodPro;
        /*
         * Contar la cantidad de municipios que tiene la provincia es coijida aleatoiramente
         */

        vTEMP := ROUND(DBMS_RANDOM.VALUE(LOW=> 1, HIGH=> vCountRow));
        -- se selecciona el numero de municipio aleatoriamente a traves de 
        -- un numero de fila generado aleatoriamente
        SELECT codMum INTO vIdsRandom.mCodMum
        FROM (
            -- crear una tabla temporal con codigos de provincias y el numero de fila en la que estan:
            SELECT codMum, ROWNUM AS rn
            FROM MUNICIPIO 
            where codPro = vIdsRandom.mCodPro
        )
        WHERE rn = vTEMP;

        select count(*) into vCountRow from APELLIDOS_FREC;
        vIdsRandom.mApellido1 := ROUND(DBMS_RANDOM.VALUE(LOW=> 1, HIGH=> vCountRow));
        vIdsRandom.mApellido2 := ROUND(DBMS_RANDOM.VALUE(LOW=> 1, HIGH=> vCountRow));


        RETURN vIdsRandom;
    END GenerarIDsDeIdentidadRandom;

    -- Función que recibe un record del tipo rIdsRandom y lo imprime
    FUNCTION outputRIdsRandom(pRegistro IN rIdsRandom) RETURN VARCHAR2 IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('mNombre: ' || pRegistro.mNombre);
        DBMS_OUTPUT.PUT_LINE('mCodPro: ' || pRegistro.mCodPro);
        DBMS_OUTPUT.PUT_LINE('mCodMum: ' || pRegistro.mCodMum);
        DBMS_OUTPUT.PUT_LINE('mApellido1: ' || pRegistro.mApellido1);
        DBMS_OUTPUT.PUT_LINE('mApellido2: ' || pRegistro.mApellido2);
        RETURN '-----------------------------';
    END outputRIdsRandom;

    
    FUNCTION ResolverIdentidadRandom(ID NUMBER, pRegistro IN rIdsRandom) RETURN rIdentidad IS
        /*
         * La funcion tiene como fin resolver un registro de tipo rIdsRandom y
         * generar un registro de tipo rIdentidad el cual sera una identidad
         * aleatoria.
         * Se debe pasar un ID numerico el cual sera el ID a asignar a esta 
         * identidad
         */
        vIdentidad rIdentidad;
        vApellido1 PERSONA.APELLIDOS%TYPE;
        vApellido2 PERSONA.APELLIDOS%TYPE;
    BEGIN
        vIdentidad.mId := ID;
        SELECT nombre   into vIdentidad.mNombre   from NOMBRES_FREC
            where pRegistro.mNombre = orden;

        SELECT appelido into vApellido1           from APELLIDOS_FREC
            where pRegistro.mApellido1 = orden;

        SELECT appelido into vApellido2           from APELLIDOS_FREC
            where pRegistro.mApellido2 = orden;
        

        -- identidades entre 18 y 100 años
        vIdentidad.mEdad := ROUND(DBMS_RANDOM.VALUE(LOW=> 18, HIGH=> 100));
        
        SELECT nombre into vIdentidad.mMunicipio       from MUNICIPIO 
            where pRegistro.mCodMum = codMum and pRegistro.mCodPro = codPro;
            
        SELECT nombre into vIdentidad.mProvincia  from PROVINCIA 
            where pRegistro.mCodPro = codPro;

        vIdentidad.mApellidos := vApellido1 || ' ' || vApellido2;

        RETURN vIdentidad;
    END ResolverIdentidadRandom;

    FUNCTION imprimirIdentidad(pIdentidad IN rIdentidad) RETURN VARCHAR2 IS
    /*
     * Funcion que imprime una identidad resuelta
     */
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ID: ' || pIdentidad.mId);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || pIdentidad.mNombre);
        DBMS_OUTPUT.PUT_LINE('Apellidos: ' || pIdentidad.mApellidos);
        DBMS_OUTPUT.PUT_LINE('Edad: ' || pIdentidad.mEdad);
        DBMS_OUTPUT.PUT_LINE('Municipio: ' || pIdentidad.mMunicipio);
        DBMS_OUTPUT.PUT_LINE('Provincia: ' || pIdentidad.mProvincia);
        RETURN '-----------------------------';
    END imprimirIdentidad;

    ----------------------------------------------------------------------------
    --                       Final de las funciones                           --
    ----------------------------------------------------------------------------
    
BEGIN

    

    DBMS_OUTPUT.PUT_LINE('Generando ' || vNIdentidades || ' identidades' );

    DBMS_OUTPUT.PUT_LINE('Generando codigo SQL para crear la secuencia de identidades:');
    -- secuencia_id_persona.nextval -> siguiente valor de la secuencia
    -- secuencia_id_persona.currval -> valor actual de la secuencia
    -- ejecutar la secuencia si no existe
    /*vSql := 'CREATE SEQUENCE secuencia_id_persona ' ||
            'START WITH 1 '                         ||
            'INCREMENT BY 1 '                       ||
            'MINVALUE 1 '                           ||
            'MAXVALUE ' || TO_CHAR(vNIdentidades)   || ' ' ||
            'NOCYCLE '                              ||
            'CACHE 20';
    DBMS_OUTPUT.PUT_LINE(vSql);
    EXECUTE IMMEDIATE vSql;*/
    

    FOR i in 1 .. vNIdentidades LOOP
        vIdsRandom := GenerarIDsDeIdentidadRandom();
        DBMS_OUTPUT.PUT_LINE(outputRIdsRandom(vIdsRandom));
        DBMS_OUTPUT.PUT_LINE('Resolviendo');
        select SECUENCIA_ID_PERSONA.nextval into vIdentidadActual from dual;
        vIdentidad := ResolverIdentidadRandom(vIdentidadActual, vIdsRandom);
        DBMS_OUTPUT.PUT_LINE(imprimirIdentidad(vIdentidad));

        INSERT INTO PERSONA VALUES(
            vIdentidad.mId,
            vIdentidad.mNombre,
            vIdentidad.mApellidos,
            vIdentidad.mEdad,
            vIdentidad.mMunicipio,
            vIdentidad.mProvincia
        );
    END LOOP;
    -- devuelve 1 si existe la secuenca(ya se creo), 0 sino
    SELECT COUNT(*) into vStatus
        FROM user_sequences
        WHERE sequence_name = 'SECUENCIA_ID_PERSONA';

    IF vStatus = 1 THEN 
        EXECUTE IMMEDIATE 'DROP SEQUENCE SECUENCIA_ID_PERSONA';
    end if;
END; 
/
COMMIT;



