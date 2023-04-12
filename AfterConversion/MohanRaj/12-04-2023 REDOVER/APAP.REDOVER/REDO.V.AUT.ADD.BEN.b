* @ValidationCode : MjotMTUwMjU3ODIyMjpDcDEyNTI6MTY4MTI4NDI4OTE2OTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Apr 2023 12:54:49
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
SUBROUTINE REDO.V.AUT.ADD.BEN
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :PRABHU.N
*Program   Name    :REDO.V.AUT.ADD.BEN
*---------------------------------------------------------------------------------

*DESCRIPTION       :It is attached as authorization routine in all the version used
*                  in the development N.83.It will fetch the value from sunnel interface
*                  and assigns it in R.NEW
*LINKED WITH       :

* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who           Reference            Description
* 28-Dec-2010        Prabhu.N       ODR-2010-08-0031   Initial Creation
* 02-09-2011         Prabhu.N       PACS00108341      modification
* 11-09-2011         PRABHU        PACS00125978        MODIFICATION
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BENEFICIARY
    $INSERT I_System



    GOSUB OPEN.PARA

    GOSUB PROCESS.PARA

    IF V$FUNCTION EQ 'R' THEN
        GOSUB LOOK.FOR.DELETION
    END
RETURN
*---------
OPEN.PARA:
*---------

    FN.CUS.BEN.LIST = 'F.CUS.BEN.LIST'
    F.CUS.BEN.LIST  = ''
    CALL OPF(FN.CUS.BEN.LIST,F.CUS.BEN.LIST)
    OWN.BEN.FLAG = ''
    OTHER.BEN.FLAG = ''
    BEN.ACCT.NO = R.NEW(ARC.BEN.BEN.ACCT.NO)
    APP.BEN = 'BENEFICIARY'
    APP.FLD = 'L.BEN.ACCOUNT'
    BEN.APP.POS = ''
    CALL MULTI.GET.LOC.REF(APP.BEN,APP.FLD,BEN.APP.POS)
    L.BEN.ACC=BEN.APP.POS<1,1>

    OTHER.BANK.BEN = R.NEW(ARC.BEN.LOCAL.REF)<1,L.BEN.ACC>
RETURN

*------------
PROCESS.PARA:
*------------

*    CUSTOMER.ID = System.getVariable('EXT.SMS.CUSTOMERS')
    CUSTOMER.ID = R.NEW(ARC.BEN.OWNING.CUSTOMER)
*PACS00125978-S/E

    BEGIN CASE
        CASE PGM.VERSION MATCHES ',AI.REDO.ADD.OWN.BANK.BEN.CONFIRM':@VM:',AI.REDO.DEL.OWN.BANK.BEN.CONFIRM':@VM:',AI.REDO.DEL.OWN.BANK.BEN':@VM:',APAP'
            GOSUB ADD.BEN.OWN
        CASE PGM.VERSION MATCHES ',AI.REDO.ADD.OTHER.BANK.BEN.CONFIRM':@VM:',AI.REDO.DEL.OTHER.BANK.BEN.CONFIRM':@VM:',AI.REDO.DEL.OTHER.BANK.BEN':@VM:',APAP.OTHER'
            GOSUB ADD.BEN.OTHER
    END CASE


RETURN
*-----------
ADD.BEN.OWN:
*-----------
    CUS.BEN.LIST.ID = CUSTOMER.ID:'-OWN'
    CALL F.READ(FN.CUS.BEN.LIST,CUS.BEN.LIST.ID,R.CUS.BEN.LIST,F.CUS.BEN.LIST,CUS.BEN.LIST.ER)
    IF NOT(CUS.BEN.LIST.ER) THEN
        OWN.BEN.FLAG=1
    END
    IF V$FUNCTION EQ 'I' OR V$FUNCTION EQ 'A' THEN
        IF R.CUS.BEN.LIST  THEN
            Y.ADD.ID.DEL = R.NEW(ARC.BEN.BEN.ACCT.NO):"*":ID.NEW
            LOCATE Y.ADD.ID.DEL IN R.CUS.BEN.LIST SETTING BEN.DEL.POS THEN
            END ELSE
                R.CUS.BEN.LIST<-1> = R.NEW(ARC.BEN.BEN.ACCT.NO):"*":ID.NEW
            END
        END ELSE
            R.CUS.BEN.LIST = R.NEW(ARC.BEN.BEN.ACCT.NO):"*":ID.NEW
        END


        CALL F.WRITE(FN.CUS.BEN.LIST,CUS.BEN.LIST.ID,R.CUS.BEN.LIST)
    END

RETURN
*-------------
ADD.BEN.OTHER:
*-------------
*PACS00108341-S/E
    CUS.BEN.LIST.ID = CUSTOMER.ID:'-OTHER'
    CALL F.READ(FN.CUS.BEN.LIST,CUS.BEN.LIST.ID,R.CUS.BEN.LIST,F.CUS.BEN.LIST,CUS.BEN.LIST.ER)
    IF NOT(CUS.BEN.LIST.ER) THEN
        OTHER.BEN.FLAG=1
    END

    IF V$FUNCTION EQ 'I' OR V$FUNCTION EQ 'A' THEN
        IF R.CUS.BEN.LIST THEN
            Y.ADD.ID.DEL =  R.NEW(ARC.BEN.LOCAL.REF)<1,L.BEN.ACC>:"*":ID.NEW
            LOCATE Y.ADD.ID.DEL IN R.CUS.BEN.LIST SETTING BEN.DEL.POS THEN
            END ELSE
                R.CUS.BEN.LIST<-1> = R.NEW(ARC.BEN.LOCAL.REF)<1,L.BEN.ACC>:"*":ID.NEW
            END
        END ELSE
            R.CUS.BEN.LIST = R.NEW(ARC.BEN.LOCAL.REF)<1,L.BEN.ACC>:"*":ID.NEW
        END
        CALL F.WRITE(FN.CUS.BEN.LIST,CUS.BEN.LIST.ID,R.CUS.BEN.LIST)
    END

RETURN

*------------------
LOOK.FOR.DELETION:
*------------------

    ID.BEN.TO.DEL = ''
    ID.ACCT.TO.DEL=''
    IF OWN.BEN.FLAG OR OTHER.BEN.FLAG THEN

        IF OWN.BEN.FLAG THEN
            ID.BEN.TO.DEL = ID.NEW
            ID.ACCT.TO.DEL=R.NEW(ARC.BEN.BEN.ACCT.NO)
            FINAL.ID.DEL = ID.ACCT.TO.DEL:"*":ID.BEN.TO.DEL
            Y.FLAG = ''
            CALL AI.REDO.CHECK.STO.TRANSFER(ID.BEN.TO.DEL,Y.FLAG)

            IF Y.FLAG EQ '1' THEN
                ETEXT ='EB-DEL.BENEFICIARY.STO'
                CALL STORE.END.ERROR
            END
        END

        IF OTHER.BEN.FLAG THEN
            ID.BEN.TO.DEL = ID.NEW
            ID.ACCT.TO.DEL = OTHER.BANK.BEN
            FINAL.ID.DEL = ID.ACCT.TO.DEL:"*":ID.BEN.TO.DEL
            Y.FLAG = ''
            CALL AI.REDO.CHECK.STO.TRANSFER(ID.BEN.TO.DEL,Y.FLAG)

            IF Y.FLAG EQ '1' THEN
                ETEXT ='EB-DEL.BENEFICIARY.STO'

                CALL STORE.END.ERROR
            END
        END

        LOCATE FINAL.ID.DEL IN R.CUS.BEN.LIST SETTING BEN.DEL.POS THEN
            DEL R.CUS.BEN.LIST<BEN.DEL.POS>
            CALL F.WRITE(FN.CUS.BEN.LIST,CUS.BEN.LIST.ID,R.CUS.BEN.LIST)
        END
    END

RETURN
END
*---------------------------------------------*END OF SUBROUTINE*-------------------------------------------
