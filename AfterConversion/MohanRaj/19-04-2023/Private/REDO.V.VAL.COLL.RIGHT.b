* @ValidationCode : MjoxOTg4MDkwMDc6Q3AxMjUyOjE2ODE4ODc1MTgyODA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:28:38
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
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.VAL.COLL.RIGHT


*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.COLL.RIGHT
* Attached as     : ROUTINE
* Primary Purpose : VERIFY THAT THE COLLATERAL TYPE EQ FROM COLLATERAL TYPE FROM
*                   COLLATERAL.RIGHT
* Incoming:
* ---------


* Outgoing:
* ---------
*
*
* Error Variables:
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Pablo Castillo De La Rosa - TAM Latin America
* Date            :
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     No changes
*19-04-2023      Mohanraj R          R22 Manual code conversion   VM TO @VM,FM TO @FM
*----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.COLLATERAL.RIGHT
    $INSERT I_F.REDO.MAX.PRESTAR.VS ;*
    $INSERT I_GTS.COMMON
    $INSERT I_System
    $INSERT I_F.REDO.FC.COLL.CODE.PARAMS
    Y.AF=AF
    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

    AF=Y.AF
RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======
    PER.OVERRIDE = ''

    VAR.CODIGO = ID.NEW
*   VAR.CODIGO = V$DISPLAY

*Set the cod for COLLATERAL.RIGHT
    VAR.CAD1   = FIELD(VAR.CODIGO, ".", 1)
    VAR.CAD2   = FIELD(VAR.CODIGO, ".", 2)
    VAR.CODIGO = VAR.CAD1:'.':VAR.CAD2

*Get information from Collateral.Right
    CALL F.READ(FN.COLL.RIGH,VAR.CODIGO,R.COLL.RIGH,F.COLL.RIGH,ERR.MSJ)

    VAR.COD.RIG = R.COLL.RIGH<COLL.RIGHT.COLLATERAL.CODE>
    VAR.COD.VH  = R.NEW(COLL.COLLATERAL.CODE)

*VERIFY THAT THE CODE FOR COLLETAL.RIGHT IS EQUAL TO COLLATERAL
    IF VAR.COD.RIG NE VAR.COD.VH THEN
        AF = COLL.COLLATERAL.CODE
        ETEXT = 'ST-COLL.VAL.COLL.RIGHT'
        CALL STORE.END.ERROR
    END

** Get the max % for the Collateral

    VAR.HOT = OFS$HOT.FIELD
    IF LEN(VAR.HOT) EQ 0 THEN
        Y.COLL.TYPE.ID = R.NEW(COLL.COLLATERAL.TYPE)
    END ELSE
        Y.COLL.TYPE.ID = COMI
    END
* PACS00306802 - S
    IF VAR.COD.RIG EQ '350' THEN
        IF PGM.VERSION MATCHES '...,REDO.MODIFICA...'  THEN
            VAR.MAX.POR = R.NEW(COLL.LOCAL.REF)<1,WPOSMAPO>
        END ELSE
            GOSUB GET.MAX.PRES.VH
        END
    END
    ELSE
        IF PGM.VERSION MATCHES '...,REDO.MODIFICA...'  THEN
            VAR.MAX.POR = R.NEW(COLL.LOCAL.REF)<1,WPOSMAPO>
        END ELSE
            CALL F.READ(FN.PARMS,Y.COLL.TYPE.ID,R.PARMS,F.PARMS,ERR.MSJ)
*      VAR.MAX.POR =  R.PARMS<2>
* Tus Start
            VAR.MAX.POR =  R.PARMS<FC.PR.PER.MAX.PRESTAR>
* Tus End
        END
    END
* PACS00306802 - E
    IF (VAR.MAX.POR) GT 0 THEN
        R.NEW(COLL.LOCAL.REF)<1,WPOSMAPO> =  VAR.MAX.POR
    END
    ELSE
        GOSUB GET.ERR.NO.PARM
    END

RETURN
*----------------------------------------------------------------------------
*
GET.MAX.PRES.VH:
*======
*
    IF Y.VALUE.DATE NE "" AND Y.BLOCK.NO NE "" AND Y.COL.SECTOR NE "" THEN

        Y.NUM.YEARS  = Y.VALUE.YEAR - Y.BLOCK.NO

        SEL.CMD  = 'SELECT ':FN.PARMS.VH
        SEL.CMD := ' WITH VEH.USE.FROM LE ' : Y.NUM.YEARS : ' AND VEH.USE.TO GE ': Y.NUM.YEARS
        SEL.CMD := ' AND VEH.TYPE = ' : Y.COL.SECTOR
        SEL.LIST = '' ; NO.OF.REC = '' ; Y.ERR = ''
        CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,Y.ERR)
        IF NO.OF.REC EQ 0 THEN
            AF = COLL.LOCAL.REF
            AV = YPOS<1,1>
            ETEXT = 'ST-PARAM.VH'
            CALL STORE.END.ERROR
        END
*
        REMOVE Y.RMPV.ID FROM SEL.LIST SETTING Y.POS
*
        GOSUB READ.PRES.VH
*
    END
*
RETURN
*----------------------------------------------------------------------------
*
GET.ERR.NO.PARM:
*======
*
    IF Y.VALUE.DATE NE "" AND Y.BLOCK.NO NE "" AND Y.COL.SECTOR NE "" THEN
        AF = COLL.LOCAL.REF
        AV = YPOS<1,4>
        ETEXT = 'ST-REDO.CCRG.MAX.POR.DEF'
        CALL STORE.END.ERROR
    END
*
RETURN
*
READ.PRES.VH:
*======
*
    Y.ERR.RMVP = ''
    CALL F.READ(FN.PARMS.VH, Y.RMPV.ID, R.PARMS.VH, F.PARMS.VH, Y.ERR.RMPV)
    IF R.PARMS.VH NE "" THEN
        VAR.MAX.POR = R.PARMS.VH<R.MPV.PERC.MAX.AMT.LOAN>
    END
*
RETURN
*
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1

    FN.COLL.RIGH    = 'F.COLLATERAL.RIGHT'
    F.COLL.RIGH     = ''
    R.COLL.RIGH     = ''

    FN.PARMS  = 'F.REDO.FC.COLL.CODE.PARAMS'
    F.PARMS   = ''
    R.PARMS   = ''
    ERR.MSJ   = ''
* PACS00306802 - S
    FN.PARMS.VH  = 'F.REDO.MAX.PRESTAR.VS'
    F.PARMS.VH   = ''
    R.PARMS.VH   = ''
    ERR.MSJ.VH   = ''
* PACS00306802 - E
    PROCESS.GOAHEAD = 1
    FN.COLLATERAL    = 'F.COLLATERAL'
    F.COLLATERAL     = ''
    R.COLLATERAL     = ''

    WCAMPO = "L.COL.LN.MX.PER":@VM:"L.COL.SEC.DESC":@VM:"L.COL.SEC.REG"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)

    YPOS=0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)

    WPOSMAPO = YPOS<1,1>
* PACS00306802 - S
    WPOSMANU = YPOS<1,2>
    WPOSNEWU = YPOS<1,3>
*
    Y.NUM.YEARS  = ''
    VAR.MAX.POR  = ''
    Y.VALUE.DATE = R.NEW(COLL.VALUE.DATE) ;* COLLATERAL CREATION DATE
    Y.BLOCK.NO   = R.NEW(COLL.LOCAL.REF)<1,WPOSMANU>          ;* MANUFACTURY DATE
    Y.COL.SECTOR = R.NEW(COLL.LOCAL.REF)<1,WPOSNEWU>          ;* NEW OR USED CONDITION
    Y.VALUE.YEAR = LEFT(Y.VALUE.DATE, 4)

* PACS00306802 - E
    Y.COLL.TYPE = COMI

    CALL System.setVariable("CURRENT.COL.TP",Y.COLL.TYPE)

RETURN

*------------------------
OPEN.FILES:
*=========

    CALL OPF(FN.COLL.RIGH,F.COLL.RIGH)
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)
    CALL OPF(FN.PARMS,F.PARMS)
    CALL OPF(FN.PARMS.VH,F.PARMS.VH)      ;* PACS00306802 - S/E
RETURN
*------------
END
