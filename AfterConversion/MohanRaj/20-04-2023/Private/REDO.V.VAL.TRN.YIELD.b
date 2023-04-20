* @ValidationCode : Mjo0Mjg2MDgxMzc6Q3AxMjUyOjE2ODE5NzUzMDI4NjY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:51:42
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
SUBROUTINE REDO.V.VAL.TRN.YIELD
*-----------------------------------------------------------------------------------------------
* Company Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed by    : Temenos Application Management
* Program Name    : REDO.V.VAL.TRN.YIELD
*-----------------------------------------------------------------------------------------------
* Description   : This is the Validation routine for the field SECURITY.CODE in SEC.TRADE
*                 & for PRICE.TYPE field in SECURITY.MASTER tables which will allow the local
*                 reference field to input only if CALCULATION.METHOD of PRICE.TYPE is PRICE/DPRICE
*
* In  Parameter : --na--
* Out Parameter : --na--
* ODR Number    : ODR-2010-07-0083
*--------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*
* 15.11.2010      Krishna Murthy T.S     SC006         INITIAL CREATION
* 04.04.2011      Pradeep S              PACS00052348  Fix for Yield Rate field
* 27.04.2011      Pradeep S              PACS00056285  Fix for SM validation
* 25.07.2011      Pradeep S              PACS00091606  Last price defaulted & MULTI.GET.LOC.REF used
*                                                      Error message used for mandartory yield input
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------------------

    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_F.PRICE.TYPE

    GOSUB INIT
    GOSUB PROCESS
RETURN

*----
INIT:
*----
*Initialising and opening necesseary Variables
    FN.SECURITY.MASTER = 'F.SECURITY.MASTER'
    F.SECURITY.MASTER = ''
    R.SECURITY.MASTER = ''
    Y.SM.ERR = ''
    CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)

    FN.PRICE.TYPE = 'F.PRICE.TYPE'
    F.PRICE.TYPE = ''
    R.PRICE.TYPE = ''
    Y.PT.ERR = ''
    CALL OPF(FN.PRICE.TYPE,F.PRICE.TYPE)

    LOC.REF.APPLICATION = "SECURITY.MASTER":@FM:"SEC.TRADE"
    LOC.REF.FIELDS = "L.SC.TRN.YIELD":@FM:"L.SC.TRN.YIELD":@VM:"L.NUM.OP.CEN"
    LOC.REF.POS = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    Y.SM.TRN.POS = LOC.REF.POS<1,1>
    Y.ST.TRN.POS = LOC.REF.POS<2,1>
    WPOSL1 = LOC.REF.POS<2,2>

*****************
    IF NOT( R.OLD(SC.SBS.CURR.NO) ) THEN
        T.LOCREF<WPOSL1, 7> = 'NOINPUT'
    END ELSE
        T.LOCREF<WPOSL1, 7> = ''
    END
*****************

*CALL GET.LOC.REF('SECURITY.MASTER','L.SC.TRN.YIELD',Y.SM.TRN.POS)
*CALL GET.LOC.REF('SEC.TRADE','L.SC.TRN.YIELD',Y.ST.TRN.POS)

RETURN

*-------
PROCESS:
*-------
*Updating the Local reference field status to 'NOINPUT'
    Y.APPL = APPLICATION
    BEGIN CASE
        CASE Y.APPL EQ "SEC.TRADE"
            Y.SEC.NO = COMI
            CALL F.READ(FN.SECURITY.MASTER,Y.SEC.NO,R.SECURITY.MASTER,F.SECURITY.MASTER,Y.SM.ERR)
            IF R.SECURITY.MASTER NE '' THEN
                Y.PRICE.TYPE = R.SECURITY.MASTER<SC.SCM.PRICE.TYPE>
                Y.LAST.PRICE = R.SECURITY.MASTER<SC.SCM.LAST.PRICE>
                IF (Y.LAST.PRICE EQ '' OR Y.LAST.PRICE EQ '0') AND R.SECURITY.MASTER<SC.SCM.BOND.OR.SHARE> EQ 'B' THEN  ;*PACS00091606 - S/E
                    R.NEW(SC.SBS.CUST.PRICE) = "0.000001"
                    R.NEW(SC.SBS.BR.PRICE) = "0.000001"
                END
                IF R.SECURITY.MASTER<SC.SCM.BOND.OR.SHARE> EQ 'S' THEN
                    GOSUB MAKE.NOINPUT
                    RETURN
                END
            END
        CASE Y.APPL EQ "SECURITY.MASTER"
            Y.PRICE.TYPE = COMI
            IF R.NEW(SC.SCM.BOND.OR.SHARE) EQ 'S' THEN
                GOSUB MAKE.NOINPUT
                RETURN
            END
    END CASE

    CALL CACHE.READ(FN.PRICE.TYPE, Y.PRICE.TYPE, R.PRICE.TYPE, Y.PT.ERR) ;*R22 Auto code conversion
    IF R.PRICE.TYPE NE '' THEN
        Y.CALC.METHOD = R.PRICE.TYPE<SC.PRT.CALCULATION.METHOD>
        GOSUB SUB.PROCESS         ;*PACS00052348 - S/E
    END
RETURN

*--------------------------------------------------------------------------------------------------
SUB.PROCESS:
*-----------
*PACS00052348 - New section

    IF Y.CALC.METHOD NE 'PRICE' THEN
        IF Y.CALC.METHOD NE 'DPRICE' THEN
            GOSUB MAKE.NOINPUT
        END ELSE
            GOSUB MAKE.MAND
        END
    END ELSE
        GOSUB MAKE.MAND
    END

RETURN


*--------------------------------------------------------------------------------------------------
MAKE.NOINPUT:
*--------------
*Updating the Status of the field as NOINPUT
    BEGIN CASE
        CASE Y.APPL EQ "SEC.TRADE"
            R.NEW(SC.SBS.LOCAL.REF)<1,Y.ST.TRN.POS> = ''
            T.LOCREF<Y.ST.TRN.POS,7> = 'NOINPUT'
        CASE Y.APPL EQ "SECURITY.MASTER"
            R.NEW(SC.SCM.LOCAL.REF)<1,Y.SM.TRN.POS> = ''
            T.LOCREF<Y.SM.TRN.POS,7> = 'NOINPUT'
    END CASE
RETURN


*--------------------------------------------------------------------------------------------------
MAKE.MAND:
*---------
*Updating the Status of the field as MANDATORY
*PACS00056285 - S/E

    BEGIN CASE
        CASE Y.APPL EQ "SEC.TRADE"
            T.LOCREF<Y.ST.TRN.POS,7> = ''
            T.LOCREF<Y.ST.TRN.POS,2> = T.LOCREF<Y.ST.TRN.POS,2>:".1"
        CASE Y.APPL EQ "SECURITY.MASTER"
            T.LOCREF<Y.SM.TRN.POS,7> = ''
            T.LOCREF<Y.SM.TRN.POS,2> = T.LOCREF<Y.SM.TRN.POS,2>:".1"
    END CASE

RETURN

END
