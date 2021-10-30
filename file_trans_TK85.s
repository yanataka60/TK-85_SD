LEDREG		EQU		83ECH      ;TK85 MONITOR
RGDSP		EQU		01A1H      ;TK85 MONITOR
MONST		EQU		007CH      ;TK85 MONITOR
MIN			EQU		7C6FH      ;TK85 WORK -(8391H)
MAX			EQU		7C00H      ;TK85 WORK -(83FFH+1)

FNAME		EQU		83E6H      ;DEレジスタセーブエリアを流用
SADRS		EQU		83E8H      ;BCレジスタセーブエリアを流用
EADRS		EQU		83EAH      ;AFレジスタセーブエリアを流用

;F9H PORTB Bit(INPUT)
;7 IN			A37
;6 IN			A36
;5 IN			A35
;4 IN			A34
;3 IN			A33
;2 IN CHK		A32		9(FLG)
;1 IN			A31
;0 IN 受信データ	A30		8(OUT)

;FAH PORTC Bit(OUTPUT)
;7 OUT
;6 OUT
;5 OUT
;4 OUT
;3 OUT 			A41
;2 OUT	FLG		A40		7(CHK)
;1 OUT			A39
;0 OUT 送信データ	A38		6(IN)

;		位置合わせ
		ORG		0000H
		DB		0FFH
		
       ORG		425H

		JP		SDLOAD
		JP		SDSAVE

;受信ヘッダ情報をセットし、SDカードからLOAD実行
;FNAME <- 0000H～FFFFHを入力。
;         ファイルネームは「xxxx.BTK」となる。
SDLOAD:	CALL	INIT
		LD		A,81H
		CALL	SNDBYTE    ;LOADコマンド81Hを送信
		CALL	RCVBYTE    ;状態取得(00H=OK)
		AND		A          ;00以外ならERROR
		JP		NZ,SVERR
		LD		HL,FNAME   ;FNAME <- LEDREG
TKMODE5:LD		DE,LEDREG
TKMD5:	LD		A,(DE)     ;FNAME取得
		LD		(HL),A
		INC		HL
		INC		DE
		LD		A,(DE)
		LD		(HL),A
		LD		HL,FNAME   ;FNAME送信
		LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		LD		A,(HL)
		CALL	SNDBYTE
		CALL	RCVBYTE    ;状態取得(00H=OK)
		AND		A          ;00以外ならERROR
		JP		NZ,SVERR
		CALL	HDRCV      ;ヘッダ情報受信
		CALL	DBRCV      ;データ受信
		JP		SDSV3      ;LOAD情報表示

;送信ヘッダ情報をセットし、SDカードへSAVE実行
;FNAME <- 0000H～FFFFHを入力。
;         ファイルネームは「xxxx.BTK」となる。
;SADRS <- 保存開始アドレス(8000H固定)
;EADRS <- 保存終了アドレス(8390H固定)

SDSAVE:	LD		HL,SADRS
		LD		(HL),00H
		INC		HL
		LD		(HL),80H   ;SADRS <- 8000H
		INC		HL         ;HL <- EADRS
		LD		(HL),090H
		INC		HL
		LD		(HL),083H  ;EADRS <- 8390H
		CALL	INIT
SDSAVE2:
		LD		A,80H
		CALL	SNDBYTE    ;SAVEコマンド80Hを送信
		CALL	RCVBYTE    ;状態取得(00H=OK)
		AND		A          ;00以外ならERROR
		JP		NZ,SVERR
		LD		HL,FNAME   ;FNAME <- LEDREG
TKMODE4:LD		DE,LEDREG
TKMD4:	LD		A,(DE)     ;FNAME取得
		LD		(HL),A
		INC		HL
		INC		DE
		LD		A,(DE)
		LD		(HL),A
		CALL	HDSEND     ;ヘッダ情報送信
		CALL	RCVBYTE    ;状態取得(00H=OK)
		AND		A          ;00以外ならERROR
		JP		NZ,SVERR
		CALL	DBSEND     ;データ送信
SDSV3:	CALL	OKDSP      ;SAVE情報表示
MONRET:	JP		MONST;MONITOR復帰(TK85)

SVERR:	CALL	ERRDSP     ;FFH:FILE OPEN ERROR F0H:SDカード初期化ERROR
		JP		MONRET     ;F1H;FILE存在ERROR

;ヘッダ送信
HDSEND:	LD		B,06H
		LD		HL,FNAME   ;FNAME送信、SADRS送信、EADRS送信
HDSD1:	LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		DEC		B
		JP		NZ,HDSD1
		RET

;データ送信
;SADRSからEADRSまでを送信
DBSEND:	LD		HL,(EADRS)
		EX		DE,HL
		LD		HL,(SADRS)
DBSLOP:	LD		A,(HL)
		CALL	ADRSDSP
		CALL	SNDBYTE
		LD		A,H
		CP		D
		JP		NZ,DBSLP1
		LD		A,L
		CP		E
		JP		Z,DBSLP2   ;HL = DE までLOOP
DBSLP1:	INC		HL
		JP		DBSLOP
DBSLP2:	RET

;SAVE、LOAD中経過表示
ADRSDSP:
		PUSH	HL
		PUSH	DE
		PUSH	AF
		EX		DE,HL      ;LEDREG <- 現在ADRS
		LD		HL,LEDREG
		LD		A,(DE)
		LD		(HL),A
		INC		DE
		INC		HL
		LD		A,(DE)
		LD		(HL),A
		INC		HL
		LD		DE,SADRS   ;LEDREG+2 <- SADRS
		LD		A,(DE)
		LD		(HL),A
		INC		DE
		INC		HL
		LD		A,(DE)
		LD		(HL),A
		CALL	RGDSP
		POP		AF
		POP		DE
		POP		HL
		RET

;SAVE、LOAD正常終了ならSADRS、EADRSをLEDに表示
OKDSP:
TKMODE6:LD		HL,LEDREG
TKMD6:	LD		DE,EADRS  ;LEDREG <- EADRS
		LD		A,(DE)
		LD		(HL),A
		INC		DE
		INC		HL
		LD		A,(DE)
		LD		(HL),A
		INC		HL
		LD		DE,SADRS  ;LEDREG+2 <- SADRS
		LD		A,(DE)
		LD		(HL),A
		INC		DE
		INC		HL
		LD		A,(DE)
		LD		(HL),A
OKDSP2:	
TKMODE2:CALL	RGDSP
		RET

;ヘッダ受信
HDRCV:	LD		HL,SADRS+1 ;SADRS取得
		CALL	RCVBYTE
		LD		(HL),A
		DEC		HL
		CALL	RCVBYTE
		LD		(HL),A
		LD		HL,EADRS+1 ;EADRS取得
		CALL	RCVBYTE
		LD		(HL),A
		DEC		HL
		CALL	RCVBYTE
		LD		(HL),A
		RET

;データ受信
DBRCV:	LD		HL,(EADRS)
		EX		DE,HL
		LD		HL,(SADRS)
DBRLOP:	CALL	ADRSDSP
		CALL	RCVBYTE
		LD		B,A
		CALL	JOGAI     ;WORKエリアを識別してSKIP
		AND		A
		JP		NZ,SKIP
		LD		A,B
		LD		(HL),A
SKIP:	LD		A,H
		CP		D
		JP		NZ,DBRLP1
		LD		A,L
		CP		E
		JP		Z,DBRLP2   ;HL = DE までLOOP
DBRLP1:	INC		HL
		JP		DBRLOP
DBRLP2:	RET
		
;SAVE、LOADエラー終了処理(F0H又はFFHをLEDに表示)
ERRDSP: PUSH	AF
TKMODE7:LD		HL,LEDREG
TKMD7:	POP		AF
		LD		(HL),A
		INC		HL
		LD		(HL),A
		INC		HL
		LD		(HL),A
		INC		HL
		LD		(HL),A
		JP		OKDSP2

		ORG		6E7H

;1BYTE送信
;Aレジスタの内容を下位BITから送信
SNDBYTE:PUSH 	BC
		LD		B,08H
SBLOP1:	RRCA               ;最下位BITをCフラグへ
		PUSH	AF
		JP		NC,SBRES   ;Cフラグ = 0
SBSET:	LD		A,01H      ;Cフラグ = 1
		JP		SBSND
SBRES:	LD		A,00H
SBSND:	CALL	SND1BIT    ;1BIT送信
		POP		AF
		DEC		B
		JP		NZ,SBLOP1  ;8BIT分LOOP
		POP		BC
		RET
		
;1BIT送信
;Aレジスタ(00Hor01H)を送信する
SND1BIT:
		OUT		(0FBH),A    ;PORTC BIT0 <- A(00H or 01H)
		LD		A,05H
		OUT		(0FBH),A    ;PORTC BIT2 <- 1
		CALL	F1CHK      ;PORTB BIT2が1になるまでLOOP
		LD		A,04H
		OUT		(0FBH),A    ;PORTC BIT2 <- 0
		CALL	F2CHK      ;PORTB BIT2が0になるまでLOOP
		RET
		
;1BYTE受信
;受信DATAをAレジスタにセットしてリターン
RCVBYTE:PUSH 	BC
		LD		C,00H
		LD		B,08H
RBLOP1:	CALL	RCV1BIT    ;1BIT受信
		AND		A          ;A=0?
		LD		A,C
		JP		Z,RBRES    ;0
RBSET:	INC		A          ;1
RBRES:	RRCA               ;Aレジスタ右SHIFT
		LD		C,A
		DEC		B
		JP		NZ,RBLOP1  ;8BIT分LOOP
		LD		A,C        ;受信DATAをAレジスタへ
		POP		BC
		RET
		
;1BIT受信
;受信BITをAレジスタに保存してリターン
RCV1BIT:CALL	F1CHK      ;PORTB BIT2が1になるまでLOOP
		LD		A,05H
		OUT		(0FBH),A    ;PORTC BIT2 <- 1
		IN		A,(0F9H)    ;PORTB BIT0
		AND		01H
		PUSH	AF
		CALL	F2CHK      ;PORTB BIT2が0になるまでLOOP
		LD		A,04H
		OUT		(0FBH),A    ;PORTC BIT2 <- 0
		POP		AF         ;受信DATAセット
		RET
		
;BUSYをCHECK(1)
; 81H BIT2が1になるまでLOP
F1CHK:	IN		A,(0F9H)
		AND		04H        ;PORTB BIT2 = 1?
		JP		Z,F1CHK
		RET

;BUSYをCHECK(0)
; 81H BIT2が0になるまでLOOP
F2CHK:	IN		A,(0F9H)
		AND		04H        ;PORTB BIT2 = 0?
		JP		NZ,F2CHK
		RET

;WORKエリアを識別
;8391H～83FFHはLOADをSKIP
JOGAI:		PUSH	HL
			PUSH	DE
			EX		DE,HL
JOGAI_TK:	LD		HL,MIN
			ADD		HL,DE
			JP		NC,JGOK    ;MIN未満ならOK
			LD		HL,MAX
			ADD		HL,DE
			JP		NC,JGERR   ;MAX未満ならSKIP
JGOK:		XOR		A          ;OKならAレジスタ=0
			JP		JGRTN
JGERR:		LD		A,01H      ;SKIP範囲ならAレジスタ=1
			JP		JGRTN
JGRTN:		POP		DE
			POP		HL
			RET

;8255初期化
INIT:
;出力BITをリセット
INIT2:	LD		A,00H      ;PORTC <- 0
		OUT		(0FAH),A
		RET
		
		END
