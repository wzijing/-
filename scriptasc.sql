SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_order]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


	CREATE procedure [dbo].[user_order]
		@user_id bigint,
		@order_id bigint,
		@begin_date datetime,
		@end_date datetime,
		@stock_id bigint,
		@type int
		--@sql nvarchar(800)output
as 
	begin
		declare @sql nvarchar(800)
		declare @test int
		set @sql=''select * from orders''
		if (@user_id is not null)
			begin
				if CHARINDEX(''where'',@sql)=0
					begin
					    set @sql=@sql +'' where user_id=''+cast(@user_id as varchar);
					end
				else
					begin
						set @sql=@sql +'' and user_id=''+cast(@user_id as varchar);
					end
				 		
			end
		if(@order_id is not null)
			begin
				if CHARINDEX(''where'',@sql)=0
					begin
						set @sql=@sql+'' where id=''+cast(@order_id as varchar);
					end
				else
					begin
							set @sql=@sql+'' and id=''+cast(@order_id as varchar);
					end
			end
			
		if(@stock_id is not null)
			begin
				if CHARINDEX(''where'',@sql)=0
					begin
						
						set @sql=@sql+'' where stock_id=''+cast(@stock_id as varchar);
					end
				else
					begin
							set @sql=@sql+'' and stock_id=''+cast(@stock_id as varchar);
					end

			end
		if(@begin_date is not null)
			begin
				if CHARINDEX(''where'',@sql)=0
					begin
						set @sql=@sql+'' where time >''+cast(@begin_date as varchar);
					end
				else
					begin
						set @sql=@sql+'' and time >''+cast(@begin_date as varchar);
					end
				
			end
		if(@end_date is not null)
			begin
			if CHARINDEX(''where'',@sql)=0
					begin
						
					set @sql=@sql+'' where time <''+cast(@end_date as varchar);
					end
				else
					begin
					set @sql=@sql+'' and time <''+cast(@end_date as varchar);
					end
				
			end
		if(@type is not null)
			begin
			if CHARINDEX(''where'',@sql)=0
					begin
						
					    set @sql=@sql+'' where type=''+cast(@type as varchar);
					end
				else
					begin
					set @sql=@sql+'' and type=''+cast(@type as varchar);
					end
			
			end

		exec(@sql)
		 
		return 
	end
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stock]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[stock](
	[id] [bigint] NOT NULL,
	[name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_stock] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[users]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[users](
	[id] [bigint] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[login_name] [varchar](50) NOT NULL,
	[passwd] [nvarchar](50) NOT NULL,
	[type] [bit] NOT NULL,
	[cny_free] [money] NOT NULL,
	[cny_freezed] [money] NOT NULL,
 CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[test]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[test](
	[name] [int] IDENTITY(3,1) NOT NULL,
	[age] [int] NOT NULL,
 CONSTRAINT [PK_test] PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[transactions]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[transactions](
	[id] [int] NOT NULL,
	[buy_order_id] [bigint] NOT NULL,
	[sell_order_id] [bigint] NOT NULL,
	[dealed] [int] NOT NULL,
	[time] [datetime] NOT NULL,
 CONSTRAINT [PK_transaction] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[orders]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[orders](
	[id] [bigint] NOT NULL,
	[user_id] [bigint] NOT NULL,
	[price] [money] NOT NULL,
	[stock_id] [bigint] NOT NULL,
	[type] [bit] NOT NULL,
	[undealed] [bigint] NOT NULL,
	[dealed] [bigint] NOT NULL,
	[canceled] [bigint] NOT NULL,
	[time] [datetime] NOT NULL,
 CONSTRAINT [PK_order] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


	CREATE trigger [make_transactions] on [dbo].[orders] for insert
as 
	declare @order_id bigint,@user_id bigint,@price money,
			@stock_id bigint,@type bit,@undealed bigint,
			@dealed bigint,@canceled bigint,@time datetime
	--????order????
	select  @order_id=id,@user_id =user_id,@price =price,@stock_id =stock_id,@type=type,@undealed=undealed,@dealed=dealed,@canceled=canceled,@time=time  
	from inserted;
	
	----------------------------public var--------------------------------------------
			declare @test int
			declare @tran_price money
			declare @cny_free money,@cny_freezed money,
				@num_free bigint,@num_freezed bigint;
			declare @swap_money money;
            declare @swap_num bigint;
		

		    declare @new_trans_id bigint
			
			
	-----------------------------------bookInfo-----------------------------------------------
--init
		-----------------------------------------------------------------
			set @cny_free=(select cny_free from users where id=@user_id);print @cny_free;
	     	set @cny_freezed=(select cny_freezed from users where id=@user_id);print @cny_freezed;
		    set @num_free=(select num_free from user_position where user_id=@user_id and stock_id=@stock_id);print @num_free;
		    set @num_freezed=(select num_freezed from user_position where user_id=@user_id and stock_id=@stock_id);print @num_freezed;
			set @dealed=(select dealed from orders where id=@order_id);
		       print 'kai shi dongjie qina'
		
		
		print'kai shi xun zhao fu he tiao jian de gupiao'

------------------------------------------------
if @type=0
	begin
		BEGIN tran tradeinfo
	begin try
			
		---------------------------freezed money--------------------------------------
			
		-----------------------------------------------------------------
		    set @cny_freezed=@cny_freezed+(@undealed*@price) 
				print 'buy is cny_freezed'
	
				print @cny_freezed
	        set @cny_free=@cny_free-(@undealed*@price)
				print 'buy is cny_free'
				print @cny_free
         update users set cny_free=@cny_free,cny_freezed=@cny_freezed where id=@user_id;
		-------------------------------------------------------------------
		
        declare @sell_order_id bigint,@sell_order_undealed int,
                @sell_order_dealed int
		declare @sell_user_id bigint
				
       /* declare @cny_free money,@cny_freezed money,
				@num_free bigint,@num_freezed bigint;*/
		
		declare @sell_cny_free money,@sell_cny_freezed money,
				@sell_num_free bigint,@sell_num_freezed bigint;

		/*declare @swap_money money;
        declare @swap_num bigint;
		

		declare @new_trans_id bigint
		
*/
		declare sell_orders cursor for
		select id,undealed,dealed from orders
               where type=1 and stock_id=@stock_id and
               price<=@price and undealed>0
		order by price,id 
		
		--declare @unprice money
		-- set @unprice=@price
		
		--?????????
		open sell_orders
			while @undealed>0
			begin
				
				fetch next from sell_orders into
                 @sell_order_id,@sell_order_undealed,
			     @sell_order_dealed
				if @@fetch_status!=0 break 
				
				print '??id';
				print @sell_order_id
                print '??wei chu li';
				print @sell_order_undealed
				print '??chu li';
				print @sell_order_dealed
				
		------------------------------freezed stock-----------------------------------------------------
		          set @sell_user_id=(select user_id from orders where id=@sell_order_id);	
                set @sell_num_freezed=(select num_freezed from user_position where user_id=@sell_user_id and stock_id=@stock_id)+@sell_order_undealed;
				set @sell_num_free=(select num_free from user_position where user_id=@sell_user_id and stock_id=@stock_id)-@sell_order_undealed;
		
				  --set @sell_num_freezed=(select num_freezed from user_position where user_id=@sell_user_id and stock_id=@stock_id);
				  --set @sell_num_free=(select num_free from user_position where user_id=@sell_user_id and stock_id=@stock_id);
				  set @sell_cny_free=(select cny_free from users where id=@sell_user_id );
				  set @sell_cny_freezed=(select cny_freezed from users where id=@sell_user_id);
				  --????
				  set @tran_price=(select price from orders where id=@sell_order_id);
				  
				  declare @chajia money
				 -- set @chajia=@unprice-@tran_price
				 
				  set @price=@tran_price;
                --  print'chajia is '
				 -- print @chajia
        ----------------------------------------------------------------------------------------
				 
				  print'?dan user_id'
				  print @sell_user_id
				  print'sell_num_freezed'
				  print @sell_num_freezed
				  print 'sell_num_free'
				  print @sell_num_free
				  print 'sell_cny_free'
				  print @sell_cny_free
				  print'sell_cny_freezed'
				  print @sell_cny_freezed

				  print'buydan user_id'
				  print @user_id
				  print'buy_num_freezed'
				  print @num_freezed
				  print 'buy_num_free'
				  print @num_free
				  print 'buy_cny_free'
				  print @cny_free
				  print'buy_cny_freezed'
				  print @cny_freezed
 
				
                --?????????
					 select @new_trans_id=isnull(max(id)+1,1) from transactions	
					if(@sell_order_undealed<@undealed) --???????????????
					begin
						set @test=1 
						      
							
							--start
							 insert into transactions
							 values(@new_trans_id,@order_id,@sell_order_id,@sell_order_undealed,getdate())
							--end	
							set @swap_money=@sell_order_undealed*@price;
							set @swap_num=@sell_order_undealed;
							set @dealed=@dealed+@swap_num;
							set @undealed=@undealed-@sell_order_undealed;
							set @sell_order_undealed=0;
                    -------------------------------------------------------
							
						
			        end
			
			---------------------------------------------------------------------------------------------------------------------
			 --?????????
			 else if(@sell_order_undealed >= @undealed)
                begin
		                set @test=2 
						
				    insert into transactions
				    values(@new_trans_id,@order_id,@sell_order_id,@undealed,getdate());	
					
					 set @swap_money=@undealed*@price;
					 set @swap_num=@undealed;
				     set @dealed=@dealed+@swap_num;
					 set @sell_order_undealed=@sell_order_undealed-@undealed
					 set @undealed=0;
					
				   
				end
				 ----------------------------update---------------------------------------------
				 update orders set dealed=@dealed,
		                           undealed=@undealed
		         where id=@order_id;
					print'swap num of gp'
					print @swap_num
					
					print'swap num of money'
					print @swap_money
					
					print'buy_cny_free'

				 update orders set dealed=@swap_num,
		                          undealed=@sell_order_undealed
		         where id=@sell_order_id;
				 /* declare @totalchajia money
				  set @totalchajia=@chajia*@swap_num
				 print'totalchajia is '
				 print @totalchajia
				 */	
                 update users set cny_free=@cny_free,cny_freezed=@cny_freezed-@swap_money where id=@user_id;
				 ----------------------buy itself--------------------------------------------------
				  
				  set @sell_cny_free=(select cny_free from users where id=@sell_user_id );
				  set @sell_cny_freezed=(select cny_freezed from users where id=@sell_user_id);
------------------------------------------------------------------------------------
				  
                 update users set cny_freezed=@sell_cny_freezed,cny_free=(@sell_cny_free+@swap_money) where id=@sell_user_id;
				 update user_position set num_freezed=@num_freezed,num_free=(@num_free+@swap_num) where user_id=@user_id and stock_id=@stock_id;
					----------------------buy itself--------------------------------------------------
				  set @sell_num_freezed=(select num_freezed from user_position where user_id=@sell_user_id and stock_id=@stock_id);
				  set @sell_num_free=(select num_free from user_position where user_id=@sell_user_id and stock_id=@stock_id);
				------------------------------------------------------------------------------------
				 update user_position set num_free=@sell_num_free,num_freezed=@sell_num_freezed-@swap_num where user_id=@sell_user_id and stock_id=@stock_id;
				
                 
				 
					
					set @cny_freezed=@cny_freezed-@swap_money;
					--set @cny_free=@cny_free+@totalchajia
					set @num_free=@num_free+@swap_num;	
				 ------------------------------------------------------------------------------
			end --while circle is end
		close sell_orders
        deallocate sell_orders
commit tran tradeinfo		
end try
begin catch
	rollback tran tradeinfo;
end catch
		
end
--------------------------------------------------type=1---------------------------------------------------------------------------------
else

	begin
			---------------------------freezed stock--------------------------------------
		    set @num_freezed=@num_freezed+@undealed
				print 'sell num_freezed'
	
				print @num_freezed
	        set @num_free=@num_free-@undealed
				print 'buy is cny_free'
				print @num_free
		-------------------------------------------------------------------
		print 'start exec1'
-----------------------------------------------------------------------------------
		update user_position set num_freezed=@num_freezed,num_free=@num_free where user_id=@user_id and stock_id=@stock_id; 
-----------------------------------------------------------------------------------
		--declare @test int
        declare @buy_order_id bigint,@buy_order_undealed int,
                @buy_order_dealed int,@buy_price money
		declare @buy_user_id bigint
				
        /*declare @cny_free money,@cny_freezed money,
				@num_free bigint,@num_freezed bigint;
		*/
		declare @buy_cny_free money,@buy_cny_freezed money,
				@buy_num_free bigint,@buy_num_freezed bigint;
/*
		declare @swap_money money;
        declare @swap_num bigint;
		

		declare @new_trans_id bigint
	*/	

		declare buy_orders cursor for
		select id,price,undealed,dealed from orders
               where type=0 and stock_id=@stock_id and
               price>=@price and undealed>0
		order by price,id 
		
		open buy_orders
			while @undealed>0
			begin
				print'while circle is start!'
				fetch next from buy_orders into
                 @buy_order_id,@buy_price,@buy_order_undealed,
			     @buy_order_dealed
				if @@fetch_status!=0 break 
	----------------------------------------freezed money----------------------------------------------------------------
                  set @buy_user_id=(select user_id from orders where id=@buy_order_id);	
                  set @buy_num_freezed=(select num_freezed from user_position where user_id=@buy_user_id and stock_id=@stock_id);
				  set @buy_num_free=(select num_free from user_position where user_id=@buy_user_id and stock_id=@stock_id);
                  --set @buy_cny_freezed=(select cny_freezed from users where id=@buy_user_id);
				 -- set @buy_cny_free=(select cny_free from users where id=@buy_user_id);
				  set @buy_cny_freezed=(select cny_freezed from users where id=@buy_user_id)+(@buy_order_undealed*@buy_price);
				  set @buy_cny_free=(select cny_free from users where id=@buy_user_id)-(@buy_order_undealed*@buy_price);
				  --????
				  set @tran_price=@buy_price;
				  set @price=@tran_price;
print'exectucte here!'

print'---------------------------------------------------------------------------------------------------'
print'dong jie hou buy status'
				 print'buy dan user_id--------'
				  print @buy_user_id
				  print'@buy_num_freezed'
				  print @buy_num_freezed
				  print '@buy_num_free'
				  print @buy_num_free
				  print '@buy_cny_free'
					print @buy_cny_free
				  print'@buy_cny_freezed'
					print @buy_cny_freezed
print'--------------------------------------------------------------------------------------------------------'			
--------------------------------------------------------------------------------------------------------------
------------------------------------????,sell > buy-----------------------------------------------------
--?????????
				select @new_trans_id=isnull(max(id)+1,1) from transactions	
					if(@buy_order_undealed<@undealed) --???????????????
					begin
						print'start first'
						set @test=1 
						      
							
							--start
							 insert into transactions
							 values(@new_trans_id,@buy_order_id,@order_id,@buy_order_undealed,getdate())
							--end	
							set @swap_money=@buy_order_undealed*@price;
							set @swap_num=@buy_order_undealed;
							set @dealed=@dealed+@swap_num;
							set @undealed=@undealed-@buy_order_undealed;
							set @buy_order_undealed=0;
                    -------------------------------------------------------
							
						
			        end
---------------------------------------------------------------------------------------------------------------
----------------------------------------????,sell<buy------------------------------------------------------
 else if(@buy_order_undealed >= @undealed)
                begin
					print'start second'
		                set @test=2 
						
				    insert into transactions
				    values(@new_trans_id,@buy_order_id,@order_id,@undealed,getdate());	
					
					 set @swap_money=@undealed*@price;
					 set @swap_num=@undealed;
					 set @dealed=@dealed+@swap_num;
					 set @buy_order_undealed=@buy_order_undealed-@undealed
					 set @undealed=0;
					
				   
				end

---------------------------------------------------------------------------------------------------------------
print'---------------------------------------------------------------------------------------------------'
				 print'buy dan user_id'
				  print @user_id
				  print'@buy_num_freezed'
				  print @num_freezed
				  print '@buy_num_free'
				  print @num_free
				  print '@buy_cny_free'
					print @cny_free
				  print'@buy_cny_freezed'
					print @cny_freezed
print'--------------------------------------------------------------------------------------------------------'		
	 ----------------------------update---------------------------------------------
				 update orders set dealed=@dealed,
		                           undealed=@undealed
		         where id=@order_id;
					print'swap num of gp'
					print @swap_num
					
					print'swap num of money'
					print @swap_money
					
					print'buy_cny_free'

-------user_id is sell-----

				 update orders set dealed=@swap_num,
		                          undealed=@buy_order_undealed
		         where id=@buy_order_id;

				
				 	
                 update users set cny_free=@cny_free+@swap_money,cny_freezed=@cny_freezed where id=@user_id;
				  ----------------------buy itself--------------------------------------------------
				  
				  set @buy_cny_free=(select cny_free from users where id=@buy_user_id );
				  set @buy_cny_freezed=(select cny_freezed from users where id=@buy_user_id);
------------------------------------------------------------------------------------
				  
                 update users set cny_freezed=@buy_cny_freezed-@swap_money,cny_free=@buy_cny_free where id=@buy_user_id;
					
				 
               
				 update user_position set num_freezed=@num_freezed-@swap_num,num_free=@num_free where user_id=@user_id and stock_id=@stock_id; 
				 ----------------------buy itself--------------------------------------------------
				  set @buy_num_freezed=(select num_freezed from user_position where user_id=@buy_user_id and stock_id=@stock_id);
				  set @buy_num_free=(select num_free from user_position where user_id=@buy_user_id and stock_id=@stock_id);
				------------------------------------------------------------------------------------
              update user_position set num_free=@buy_num_free+@swap_num,num_freezed=@buy_num_freezed where user_id=@buy_user_id and stock_id=@stock_id;
				
					set @cny_free=@cny_free+@swap_money	
					set @num_freezed=@num_freezed-@swap_num

				 ------------------------------------------------------------------------------
print'----------------------------------------------------------------------------------------------'
	


print'-----------------------------------------------------------------------------------------------'		 
		
			end
		close buy_orders
        deallocate buy_orders
		
		
	end









GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_position]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_position](
	[user_id] [bigint] NOT NULL,
	[stock_id] [bigint] NOT NULL,
	[num_free] [bigint] NOT NULL,
	[num_freezed] [bigint] NOT NULL,
 CONSTRAINT [PK_user_position] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC,
	[stock_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cancel_order]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE proc [dbo].[cancel_order]
	@user_id bigint,
	@order_id bigint
as
begin
	begin tran
		begin try
		declare @isHave int
		set @isHave=0
		select @isHave=count(*) from orders where id=@order_id
		if(@isHave>0)
		begin
			declare @stock_id bigint,@type bit,@undealed bigint,@dealed bigint,@canceled bigint,@price money
			select @stock_id=stock_id,@type=type,@undealed=undealed,@dealed=dealed,@canceled=canceled,@price=price
			from orders where id=@order_id
			if(@type=0 and @undealed>0)
			begin
				--declare @cny_freezed money
				---set @cny_freezed=(select cny_freezed from users where id=@user_id)

			--select @cny_freezed=@cny_freezed-(@undealed*@price) from users where id=@user_id
				declare @swap_money money;
				set @swap_money=@undealed*@price
				update users set cny_free=cny_free+@swap_money,cny_freezed=cny_freezed-@swap_money where id=@user_id
				update orders set canceled=@undealed,undealed=0,dealed=dealed where id=@order_id 
			end
			else if (@type=1 and @undealed>0)
			begin
				--declare @num_freezed bigint
				--set @num_freezed=0
				 declare @swap_num bigint
				 set @swap_num=@undealed
				--select @num_freezed=num_freezed-@swap_num from user_position where user_id=@user_id and stock_id=@stock_id
				update user_position set num_free=num_free+@swap_num,num_freezed=num_freezed-@swap_num where user_id=@user_id and stock_id=@stock_id
				update orders set undealed=0,dealed=dealed,canceled=@undealed where id=@order_id
			end
		end
		else
		begin
			return -1
		end
		commit
		return 0		
		end try
		begin catch
			rollback
			return -2
		end catch
end


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[trade]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE proc [dbo].[trade]
	@user_id bigint,
	@stock_id bigint,
    @type bit,
	@price money,
    @ammount bigint
as
begin
		--??????????? Transact-SQL ????????
		--???Sql server??????????delete????
		--????????3?Rows Affected??
		--?   SET NOCOUNT ? OFF ??????,
		--??????????????SET NOCOUNT ON ?????
		--???????????? SET NOCOUNT OFF?????
		--?????????????
		Set NOCOUNT ON;  --??????

		--???????????????XACT_ABORT??(????Off)?
		--???????On??????????????,
		--?? transcation???uncommittable???
		--????????????????????
		--????????Off???????????????
		--??????????????????????
		Set XACT_ABORT ON;
		begin try
		begin tran
		declare @order_id bigint
		if @type=0
		begin
			declare @totalMoney money
			set @totalMoney=@price*@ammount
			declare @cny_free money
			select @cny_free=cny_free from users where id=@user_id
			if(@cny_free>@totalMoney)
			begin
				--update users set cny_free=cny_free-@totalMoney,cny_freezed=@totalMoney+cny_freezed where id=@user_id
				select @order_id=isnull(max(id)+1,1) from orders
				insert into orders values(@order_id,@user_id,@price,@stock_id,@type,@ammount,0,0,getdate())
			end
			else
			begin
				return -1
			end
		end
		else if(@type=1)
		begin
			declare @num_free bigint
			set @num_free=0
			select 	@num_free=isnull(num_free,0) from user_position where user_id=@user_id and stock_id=@stock_id
			if @num_free>=@ammount
			begin
				--update user_position set num_free=num_free-@ammount,num_freezed=@ammount+num_freezed where user_id=@user_id and stock_id=@stock_id
				select @order_id=isnull(max(id)+1,1) from orders
				insert into orders values(@order_id,@user_id,@price,@stock_id,@type,@ammount,0,0,getdate())
			end
			else
			begin
				return -2
			end
		end
		commit tran
		Set NOCOUNT OFF
		return 0
		end try
		begin catch
			rollback tran
			Set NOCOUNT OFF
			return -3
		end catch
end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GpPrice]'))
EXEC dbo.sp_executesql @statement = N'
create view [dbo].[GpPrice]
as
select 
	t1.*,
	t2.stock_id,
	t2.price as buy_price,
	t3.price as sell_price
from transactions as t1
inner join orders as t2 on t1.buy_order_id=t2.id
inner join orders as t3 on t1.sell_order_id=t3.id' 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stock_depth]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE proc [dbo].[stock_depth]
	@stock_id bigint,
	@type int
as
begin
	select price,num=sum(undealed) from orders where stock_id=@stock_id and type=@type and undealed<>0  group by price order by price,num 
end' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_stock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



CREATE procedure [dbo].[user_stock]
	@user_id bigint
as

begin
	begin tran
		begin try
			declare @num_free bigint,@num_freezed bigint
			select @num_free=num_free,@num_freezed=num_freezed from user_position where user_id=@user_id

		commit
		end try

		begin catch
			rollback
		end catch
end


-----------------------------------------------






' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_login]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

create procedure [dbo].[user_login]
	@login_name varchar(50),
	@passwd nvarchar(50),
	@user_id bigint output,
	@name varchar(50) output,
	@type int output
as
begin
	declare @count int;
	set @count=0
	select @count=count(*) from users where @login_name=login_name and @passwd=passwd
	if(@count>0)
	begin
		select @user_id=id,@name=name,@type=type from users where @login_name=login_name and @passwd=passwd
		return 0
	end
	else
	begin
		return -1
	end
end
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[getNowGpPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE proc [dbo].[getNowGpPrice]
	@stock_id bigint,
	@price money output  --????
as
begin
	set @price=0
	declare @buy_order_id bigint --???????
 	declare @sell_order_id bigint ----???????
	declare @sell_price money     --????
	declare @buy_price money      --????
	
	select 
		@buy_order_id=buy_order_id,
		@sell_order_id=sell_order_id,
		@buy_price=buy_price,
		@sell_price=sell_price
	from ( select top 1 * from GpPrice where stock_id=@stock_id order by time desc ) tab
	
	--??????????????
	if(@buy_order_id>@sell_order_id)
	begin
		set @price=@sell_price
	end
	else
	begin
		set @price=@buy_price
	end
end
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_cny]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



CREATE proc [dbo].[user_cny]
	@user_id bigint,
	@cny_free money output,
	@cny_freezed money output,
	@asset money output
as
begin
	select @cny_free=cny_free from users where id=@user_id --??????
	select @cny_freezed=cny_freezed from users where id=@user_id --?????

	--??????
	declare @stock_id bigint
	declare @num_free bigint
	declare @num_freezed bigint
	declare @gp_money money
	set @gp_money=0
	
 	declare @t table(stock_id bigint,num_free bigint,num_freezed bigint)
	

print ''hello world11''
	insert into @t(stock_id,num_free,num_freezed) exec user_stock @user_id

	declare gpNum cursor for select * from @t 

	open gpNum
	fetch next from gpNum into @stock_id,@num_free,@num_freezed

	while (@@fetch_status=0)
	begin	
		--???????????
		declare @deal_price money 
		exec getNowGpPrice @stock_id,@price=@deal_price output
		set @gp_money=@gp_money+@deal_price*(@num_free+@num_freezed)
		
		print @deal_price
		print @num_freezed
		fetch next from gpNum into @stock_id,@num_free,@num_freezed
	end
	close gpNum
	deallocate gpNum
	set @asset=@cny_free+@cny_freezed+@gp_money
	print @gp_money
end

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_transaction_order]') AND parent_object_id = OBJECT_ID(N'[dbo].[transactions]'))
ALTER TABLE [dbo].[transactions]  WITH CHECK ADD  CONSTRAINT [FK_transaction_order] FOREIGN KEY([buy_order_id])
REFERENCES [dbo].[orders] ([id])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_transaction_order1]') AND parent_object_id = OBJECT_ID(N'[dbo].[transactions]'))
ALTER TABLE [dbo].[transactions]  WITH CHECK ADD  CONSTRAINT [FK_transaction_order1] FOREIGN KEY([sell_order_id])
REFERENCES [dbo].[orders] ([id])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_order_stock]') AND parent_object_id = OBJECT_ID(N'[dbo].[orders]'))
ALTER TABLE [dbo].[orders]  WITH CHECK ADD  CONSTRAINT [FK_order_stock] FOREIGN KEY([stock_id])
REFERENCES [dbo].[stock] ([id])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'orders', @level2type=N'CONSTRAINT', @level2name=N'FK_order_stock'

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_order_users]') AND parent_object_id = OBJECT_ID(N'[dbo].[orders]'))
ALTER TABLE [dbo].[orders]  WITH CHECK ADD  CONSTRAINT [FK_order_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'orders', @level2type=N'CONSTRAINT', @level2name=N'FK_order_users'

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_position_stock]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_position]'))
ALTER TABLE [dbo].[user_position]  WITH CHECK ADD  CONSTRAINT [FK_user_position_stock] FOREIGN KEY([stock_id])
REFERENCES [dbo].[stock] ([id])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_position_users]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_position]'))
ALTER TABLE [dbo].[user_position]  WITH CHECK ADD  CONSTRAINT [FK_user_position_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
