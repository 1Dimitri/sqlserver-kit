IF OBJECT_ID('dbo.usp_TransliterationEN2RU', 'P') IS NULL
    EXECUTE ('CREATE PROCEDURE dbo.usp_TransliterationEN2RU AS SELECT 1;');
GO


ALTER PROCEDURE usp_TransliterationEN2RU
(
    @inputstring varchar(8000),
    @transid int = null
) as
/*
.EXAMPLE
  EXEC usp_TransliterationEN2RU @inputstring = '������ ���������';

.NOTE
  Author: ������ ���������
  Original link: https://github.com/shramko/mssql/blob/master/transliteration.sql
*/
BEGIN
    /*
        @transid - �� �������� ��������������. ������ ������������ ���������
        1 - � ������������ � ����������� 6 ������� ��� ������ �� 26 ��� 1997 �. N 310 http://rosadvokat.ru/open.php?id=11800742_1
        2 - � ������������ � ���� � 52535.1-2006 http://www.complexdoc.ru/pdf/%D0%93%D0%9E%D0%A1%D0%A2%20%D0%A0%2052535.1-2006/gost_r_52535.1-2006.pdf
        3 - � ������������ � �. 97 ������� ��� ������ N 320 �� 15 ������� 2012 �.[10] � ������������ � ��������������� ���� ������������� ���������� (Doc 9303, ����� 1, ���������� 9 � ������� IV) http://www.icao.int/publications/Documents/9303_p1_v1_cons_ru.pdf

    */

SET @inputstring = UPPER(@inputstring);

    DECLARE
         @outputstring VARCHAR(8000)
        ,@counter      INT
        ,@ch1          VARCHAR(10)
        ,@ch2          VARCHAR(10)
        ,@ch3          VARCHAR(10);
    
    declare 
        @result_table table (id int, translate varchar(8000))

    ------------------------------------------------------------------	
    ------- 1 - � ������������ � ����������� 6 ������� ��� ������ �� 26 ��� 1997 �. N 310 ------------------	 	 
     select  
         @counter = 1
        ,@outputstring = ''
    
    --���������� �������: � - ����� ����� �������� ���������� - ss - Goussev.
    declare @t1 table (ch char)
    insert into @t1
              select '�'
        union select '�'
        union select '�'
        union select '�'
        union select '�'
        union select '�'
        union select '�'
        union select '�'
        union select '�'
        union select '�'
    
    declare @t2 table (ch char)
    insert into @t2
        select '�';
    
    declare @str varchar(4000) = '';
    select @str = @str + t1.ch + t2.ch + t3.ch + '|' from @t1 t1, @t2 t2, @t1 t3
    -----------------------------------------------------------------------------
    -- exec transliteration '�������� �����. ������ ��� � ���� ���� ������ ' , 1
    while (@counter <= len(@inputstring))
    begin
        select @ch1 = substring(@inputstring,@counter,1)
        select @ch2 = substring(@inputstring,@counter,2)


        select  
            @outputstring = @outputstring + 
                case
                    when J8 > 0 then 
                                    case 
                                        when @ch2 collate Cyrillic_General_CS_AS = upper(@ch2) then'INE'
                                        else 'ine'
                                    end
                    when J7 > 0 then 
                                    case 
                                        when @ch2 collate Cyrillic_General_CS_AS = upper(@ch2) then'IE'
                                        else 'ie'
                                    end
                    when J6 > 0 then 
                                    case 
                                        when @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) then'X'
                                        else 'x'
                                    end
                    when J5 > 0 then 
                                    case 
                                        when @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) then 'SS'
                                        else 'ss'
                                    end
                    when J4 > 0 then 
                                    case
                                        when @ch2 collate Cyrillic_General_CS_AS = upper(@ch2) then 'GUIA'	
                                        when @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) then 'Guia'																																																											
                                        else 'guia'
                                    end
                    when J3 > 0 then 
                                    case
                                        when @ch2 collate Cyrillic_General_CS_AS = upper(@ch2) then 'GUIOU'	
                                        when @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) then 'Guiou'																																																											
                                        else 'guiou'
                                    end
                    when J2 > 0 then replace(substring(
                                                        case
                                                            when @ch2 collate Cyrillic_General_CS_AS = upper(@ch2) then '|GUE|GUE|GUI|GUI|GUY'	
                                                            when @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) then '|Gue|Gue|Gui|Gui|Guy'																																																											
                                                            else '|gue|gue|gui|gui|guy'
                                                        end, J2 + 1, 3), '|', '')
                    when J1 > 0 then substring(
                                                case 
                                                    when @ch2 collate Cyrillic_General_CS_AS = upper(@ch2) then 'OUKHTSCHIA'
                                                    when @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) then 'OuKhTsChIa'
                                                    else 'oukhtschia'
                                                end, J1*2 - 1, 2)
                    when J11 > 0 then substring(
                                                case 
                                                    when @ch2 collate Cyrillic_General_CS_AS = upper(@ch2) then 'TCHIOU'
                                                    when @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) then 'TchIou'
                                                    else 'tchiou'
                                                end, J11*J11, 3) 
                    when J0 > 0 then substring(
                                                CASE 
                                                    WHEN @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) then 'ABVGDEEJZIYKLMNOPRSTFYE'
                                                    ELSE 'abvgdeejziyklmnoprstfye'
                                                END, J0, 1)
                    ELSE CASE 
                            WHEN @ch2 collate Cyrillic_General_CS_AS = upper(@ch2) then replace(@ch1,'�','SHTCH')
                            WHEN @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) then replace(@ch1,'�','Shtch')
                            ELSE replace(@ch1,'�','shtch')
                         END 
                end
            ,@counter = @counter + 
                case					
                    when J2 + J3 + J4 + J6 + J7 + J8 >0 then 2
                    else 1
                end
        FROM (
            SELECT
                 PATINDEX('%|' + SUBSTRING(@inputstring,@counter,3) + '|%','|�� |��,|��.|��;|��:|' )    AS J8 -- ������� �� "��" ������� � "e" - Vassine - �����.
                ,PATINDEX('%|' + SUBSTRING(@inputstring,@counter,2) + '|%','|��|ܨ|' )                  AS J7 -- ���� � ������� ����� "�" ������� "e", �� ������� "ie"
                ,PATINDEX('%|' + SUBSTRING(@inputstring,@counter,2) + '|%','|��|' )                     AS J6 -- ��������� "��" �� ����������� ������ ������� ��� "�"
                ,PATINDEX('%|' + SUBSTRING(@inputstring,@counter-1,3) + '|%','|'+ @str )                AS J5 -- � - ����� ����� �������� ���������� - ss
                ,PATINDEX('%|' + SUBSTRING(@inputstring,@counter,2) + '|%','|��|' )                     AS J4 --G,g ����� e, i, � ������� � "u" (gue, gui, guy)
                ,PATINDEX('%|' + SUBSTRING(@inputstring,@counter,2) + '|%','|��|' )                     AS J3 --G,g ����� e, i, � ������� � "u" (gue, gui, guy)
                ,PATINDEX('%|' + SUBSTRING(@inputstring,@counter,2) + '|%','|��||��||��||��||��|')      AS J2 --G,g ����� e, i, � ������� � "u" (gue, gui, guy)
                ,PATINDEX('%'  + SUBSTRING(@inputstring,@counter,1) +  '%','�����')                     AS J1
                ,PATINDEX('%'  + SUBSTRING(@inputstring,@counter,1)  +  '%','��')                        AS J11
                ,PATINDEX('%'  + SUBSTRING(@inputstring,@counter,1) +  '%','�����Ũ������������������') AS J0
            ) J
    END;

    insert into @result_table
    select 1, @outputstring;


    ------------------------------------------------------------------	
    ------- 2 - � ������������ � ���� � 52535.1-2006 ------------------	 
     SELECT
         @counter = 1
        ,@outputstring = '';

    WHILE (@counter <= len(@inputstring))
    BEGIN
        SELECT @ch1 = SUBSTRING(@inputstring,@counter,1)
        SELECT @ch2 = SUBSTRING(@inputstring,@counter,2)
        SELECT
            @outputstring = @outputstring + 
                CASE
                    
                    WHEN J1 > 0 THEN SUBSTRING(CASE
                                                    WHEN @ch2 COLLATE Cyrillic_General_CS_AS = upper(@ch2) THEN 'ZHKHTCCHSHIAIU'
                                                    WHEN @ch1 COLLATE Cyrillic_General_CS_AS = upper(@ch1) THEN 'ZhKhTcChShIaIu'
                                                    ELSE 'zhkhtcchshiaiu'
                                                END, J1*2 - 1, 2)

                    WHEN J0 > 0 THEN substring(CASE
                                                    WHEN @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) THEN 'ABVGDEEZIIKLMNOPRSTUFYE'
                                                    ELSE 'abvgdeeziiklmnoprstufye'
                                                END, J0, 1)

                    ELSE CASE
                            WHEN @ch2 COLLATE Cyrillic_General_CS_AS = UPPER(@ch2) then REPLACE(@ch1,'�','SHCH')
                            WHEN @ch1 COLLATE Cyrillic_General_CS_AS = UPPER(@ch1) then REPLACE(@ch1,'�','Shch')
                            ELSE REPLACE(@ch1,'�','shch')
                         END
                end
            ,@counter = @counter + 1
        FROM (
                SELECT
                     PATINDEX('%' + @ch1 + '%','�������') as J1
                    ,PATINDEX('%' + @ch1 + '%','�����Ũ������������������') as J0
              ) J
    end

    insert into @result_table (id, translate)
        select 2, @outputstring
    

    ------------------------------------------------------------------	
    ------- 3 - � ������������ � �. 97 ������� ��� ������ N 320 �� 15 ������� 2012 �.[10] � ������������ � ��������������� ���� ������������� ���������� (Doc 9303, ����� 1, ���������� 9 � ������� IV) ------------------	 
     select  		 
         @counter = 1
        ,@outputstring = ''
         
    WHILE (@counter <= len(@inputstring))
    BEGIN
        SELECT @ch1 = substring(@inputstring,@counter,1);
        SELECT @ch2 = substring(@inputstring,@counter,2);

        SELECT
            @outputstring = @outputstring + 
                CASE
                    WHEN J1 > 0 THEN substring( case 
                                                    when @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) THEN 'ZHKHTSCHSHIAIUIE'
                                                    else 'zhkhtschshiaiuie'
                                                end	, J1*2 - 1, 2)				

                    WHEN J0 > 0 THEN substring(CASE
                                                    WHEN @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) THEN 'ABVGDEEZIYKLMNOPRSTUFYE'
                                                    ELSE 'abvgdeeziyklmnoprstufye'
                                                END, J0, 1)

                    ELSE CASE
                            WHEN @ch2 collate Cyrillic_General_CS_AS = upper(@ch2) then replace(@ch1,'�','SHCH')
                            WHEN @ch1 collate Cyrillic_General_CS_AS = upper(@ch1) then replace(@ch1,'�','Shch')
                            ELSE replace(@ch1,'�','shch')
                         END
                END
            ,@counter = @counter + 1
        FROM (
                SELECT
                     PATINDEX('%' + @ch1 + '%','��������') as J1
                    ,PATINDEX('%' + @ch1 + '%','�����Ũ�����������������'       ) as J0
              ) J
    END;

    insert into @result_table (id, translate)
        select 3, @outputstring;

    --------������� ���������------------------------	
    SELECT *
    FROM
        @result_table
    WHERE
        (@transid is not null and id = @transid)
        or (id is not null and @transid is null);

END;
GO
