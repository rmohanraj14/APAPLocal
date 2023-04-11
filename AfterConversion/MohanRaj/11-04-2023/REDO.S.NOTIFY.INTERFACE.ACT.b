* @ValidationCode : Mjo5NDg5ODQzMDc6Q3AxMjUyOjE2ODEyMTQ5NzEyOTk6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:39:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.NOTIFY.INTERFACE.ACT(INT.CODE, INT.TYPE, MON.TP, DESC, REC.CON, BAT.NO, BAT.TOT, INFO.OR, INFO.DE, ID.PROC, EX.USER, EX.PC)
*-----------------------------------------------------------------------------
* Developer    : Mauricio Sthandier (msthandier@temenos.com)
*                TAM Latin America
* Client       : Asociacion Popular de Ahorro & Prestamo (APAP)
* Date         : 04.16.2014
* Description  : Routine for encapsulating events record and notification
* Type         : Routine
* Attached to  : REDO.INTERFACE.PARAM,MAN>VPL00X
* Dependencies : NA
*-----------------------------------------------------------------------------
* Modification History:
*
* Version   Date           Who            Reference         Description
* 1.0       04.16.2014     msthandier     -                 Initial Version
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM, ++ TO +=1,
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.INTERFACE.PARAM
    $INSERT I_TAM.EMAIL.COMMON

    GOSUB INIT
    GOSUB PROCESS

INIT:
    FN.REDO.INTERFACE.PARAM = 'F.REDO.INTERFACE.PARAM'
    F.REDO.INTERFACE.PARAM = ''
    R.REDO.INTERFACE.PARAM = ''

    Y.ERROR = ''

    FN.REDO.SEND.EMAIL.LIST = 'F.REDO.SEND.EMAIL.LIST'
    F.REDO.SEND.EMAIL.LIST = ''
    CALL OPF(FN.REDO.SEND.EMAIL.LIST, F.REDO.SEND.EMAIL.LIST)

    T.DIR = '/tmp'
    OPENSEQ T.DIR,INT.CODE TO FILE
    ELSE CREATE FILE ELSE CALL TRANSACTION.ABORT ;*R22 Auto code conversion
    CLOSESEQ FILE

RETURN

***************************************
* Record the event and notify @FROM @TO
PROCESS:
***************************************
    CALL REDO.INTERFACE.REC.ACT(INT.CODE,INT.TYPE,BAT.NO,BAT.TOT,INFO.OR,INFO.DE,ID.PROC,MON.TP,DESC,REC.CON,EX.USER,EX.PC)

*  CALL OPF(FN.REDO.INTERFACE.PARAM, F.REDO.INTERFACE.PARAM)
    CALL CACHE.READ(FN.REDO.INTERFACE.PARAM, INT.CODE, R.REDO.INTERFACE.PARAM, Y.ERR)
* msth: until the below code works
* CALL REDO.R.BCR.REPORT.DELIVERY(Y.INT.CODE,'ONLINE',R.REDO.INTERFACE.PARAM)

    fieldParamType = R.REDO.INTERFACE.PARAM<REDO.INT.PARAM.PARAM.TYPE>
    fieldParamValue = R.REDO.INTERFACE.PARAM<REDO.INT.PARAM.PARAM.VALUE>
    R.EMAIL = ""
    R.EMAIL<E_MAIL.PASSWORD> = ""
    paramType = 'FROM'
    GOSUB GET.PARAM.TYPE.VALUE
    R.EMAIL<E_MAIL.FROM> = paramValue
    paramType = 'TO'
    GOSUB GET.PARAM.TYPE.VALUE
    R.EMAIL<E_MAIL.TO> = paramValue
    R.EMAIL<E_MAIL.TYPE> = "His"
    R.EMAIL<E_MAIL.SUBJECT> = REC.CON
    R.EMAIL<E_MAIL.BODY> = DESC

*    CALL ALLOCATE.UNIQUE.TIME(UNIQUE.TIME)
*    VAR.UNIQUE.ID=UNIQUE.TIME
*    CALL F.WRITE(FN.REDO.SEND.EMAIL.LIST,VAR.UNIQUE.ID,R.EMAIL,F.REDO.SEND.EMAIL.LIST,E.WRITE.ERR)

*    CALL TAM.EMAIL.SEND.R(R.EMAIL, Y.ERROR)
*    paramType = 'VERSION.USED'
*    GOSUB GET.PARAM.TYPE.VALUE

    paramType = "VERSION.USED"
    PARAM.COUNT = DCOUNT(fieldParamValue,@VM)

    ITER = 1
    VERSION.FOUND = 'N'
    VERSION.USED = APPLICATION : PGM.VERSION

    LOOP
    WHILE ITER LE PARAM.COUNT
        IF fieldParamType<1,ITER> EQ paramType THEN
            IF fieldParamValue<1,ITER> EQ VERSION.USED THEN
                VERSION.FOUND = 'Y'
                ITER = PARAM.COUNT
            END
        END
        ITER += 1
    REPEAT
    IF VERSION.FOUND EQ 'Y' THEN
        CALL ALLOCATE.UNIQUE.TIME(UNIQUE.TIME)
        VAR.UNIQUE.ID=UNIQUE.TIME
        CALL F.WRITE(FN.REDO.SEND.EMAIL.LIST,VAR.UNIQUE.ID,R.EMAIL)
    END ELSE
        CALL TAM.EMAIL.SEND.R(R.EMAIL, Y.ERROR)
    END
RETURN

*************************
* Retrieve MV param/value
GET.PARAM.TYPE.VALUE:
*************************
    valueNo = 0
    paramValue = ""
    LOCATE paramType IN fieldParamType<1,1> SETTING valueNo THEN
        paramValue = fieldParamValue<1, valueNo>
    END ELSE
        valueNo = 0
    END

RETURN

END
