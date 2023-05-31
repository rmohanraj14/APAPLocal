* @ValidationCode : MjotMTI1NTY0MTg5MjpDcDEyNTI6MTY4MDE5MDE1ODY0OTpJVFNTOi0xOi0xOjM0OToxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 349
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE APAP.AA
SUBROUTINE REDO.S.FC.AA.COLLATERAL(AA.ID, CU.DET.ARR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.E.NOF.DATCUST
* Attached as     : ROUTINE
* Primary Purpose :
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
* AA.ARR - data returned to the routine
*
* Error Variables:
*-----------------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Juan Pablo Armas - TAM Latin America
* Date            :
*
*
* Date             Who                   Reference      Description
* 30.03.2023       Conversion Tool       R22            Auto Conversion     - VM TO @VM, I TO I.VAR
* 30.03.2023       Shanmugapriya M       R22            Manual Conversion   - No changes
*-------------------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.REDO.FC.ENQPARMS

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======

    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,LOC.REF.POS)
    Y.REV.RT.TYPE.POS = LOC.REF.POS<1,1>
*DEBUG
    IF Y.REV.RT.TYPE.POS GT 0 THEN
        CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARRG.ID, PROPERTY.CLASS,'','', RET.IDS, INT.COND, RET.ERR)
        Y.COLL.ID = INT.COND<1,AA.AMT.LOCAL.REF,Y.REV.RT.TYPE.POS>        ;* This hold the Value in the local field
        CALL F.READ(FN.COLLATERAL,Y.COLL.ID,R.COLLATERAL,F.COLLATERAL,"")
        IF R.COLLATERAL THEN
            GOSUB AA.COLL.TYPE
            IF R.REDO.FC.ENQPARMS THEN
                NRO.FIELDS = DCOUNT(R.REDO.FC.ENQPARMS<FC.PG.CAMPO>,@VM)
                FOR I.VAR=1 TO NRO.FIELDS   ;** R22 Auto conversion - I TO I.VAR
                    Y.CUR.CAMPO = R.REDO.FC.ENQPARMS<FC.PG.CAMPO,I.VAR>   ;** R22 Auto conversion - I TO I.VAR
                    GOSUB GETPOSVALFLD
                    CHANGE @VM TO '_' IN Y.VALUE.FLD
                    CU.DET.ARR <-1> = Y.VALUE.FLD
                NEXT
            END
        END
    END

RETURN
*----------------------------------------------------------------------------
GETPOSVALFLD:
*===========
    Y.OPFLD = FIELD(Y.CUR.CAMPO,'.',1)
    IF Y.OPFLD EQ "L" THEN
*Campos locales
        Y.FIELD.NAME = Y.CUR.CAMPO
        Y.FIELD.NO = 0
        CALL GET.LOC.REF ('COLLATERAL',Y.FIELD.NAME,Y.FIELD.NO)
        Y.FIELDLOC.NO = Y.FIELD.NO
        Y.FIELD.NO = "LOCAL.REF"
        CALL EB.FIND.FIELD.NO('COLLATERAL', Y.FIELD.NO)
        IF Y.FIELD.NO AND Y.FIELDLOC.NO THEN
            Y.VALUE.FLD =  R.COLLATERAL <Y.FIELD.NO,Y.FIELDLOC.NO>
        END ELSE
            Y.VALUE.FLD = Y.CUR.CAMPO:"*NO.EXISTE"
        END

    END ELSE
*DEBUG
*Campos de la aplicacion
        Y.FIELD.NO = Y.CUR.CAMPO
        IF Y.CUR.CAMPO EQ "@ID" THEN
            Y.VALUE.FLD = Y.COLL.ID
        END ELSE
            CALL EB.FIND.FIELD.NO('COLLATERAL', Y.FIELD.NO)
            IF Y.FIELD.NO THEN
                Y.VALUE.FLD =  R.COLLATERAL <Y.FIELD.NO>
            END ELSE
                Y.VALUE.FLD = Y.CUR.CAMPO:"*NO.EXISTE"
            END
        END
    END
    IF NOT(Y.VALUE.FLD) THEN
        Y.VALUE.FLD = Y.CUR.CAMPO:"*NULO"
    END ELSE
        Y.VALUE.FLD = Y.CUR.CAMPO:"*":Y.VALUE.FLD
    END

RETURN
*----------------------------------------------------------------------------
AA.COLL.TYPE:
*============

*         COLLATERAL TYPES
*         A.Garantía Hipotecaria: Bienes Raíces y Habitacionales --->> GAR.HIP.BRH-----450
*         B. Títulos Públicos---->> GAR.TIT.PUB ---100
*         C. Depositos en APAP---->> GAR.DEPAPAP---150
*         D. Depositos en Otras Entidades--->>GAR.DEPOENT----200
*         E. Vehiculos Nuevos y Usados-->>GAR.VEHNU----350
*         F. Firmas Solidarias--->>GAR.FIRSOL-----970
    Y.COL.CODE = R.COLLATERAL<COLL.COLLATERAL.CODE>
    Y.AA.COLL.TYPE = 'GAR.':Y.COL.CODE
    CALL F.READ(FN.REDO.FC.ENQPARMS,Y.AA.COLL.TYPE,R.REDO.FC.ENQPARMS,F.REDO.FC.ENQPARMS,"")

RETURN
*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
    B.CONT = 0
    Y.ARRG.ID = AA.ID

    PROPERTY.CLASS = 'TERM.AMOUNT'
    LOC.REF.APPL="AA.ARR.TERM.AMOUNT"
    LOC.REF.FIELDS="L.AA.COL"
    LOC.REF.POS=" "

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL  = ''
    R.COLLATERAL = ''

    FN.REDO.FC.ENQPARMS = 'F.REDO.FC.ENQPARMS'
    F.REDO.FC.ENQPARMS  = ''
    R.REDO.FC.ENQPARMS  = ''

RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)
    CALL OPF (FN.REDO.FC.ENQPARMS, F.REDO.FC.ENQPARMS)
RETURN
*------------
END
