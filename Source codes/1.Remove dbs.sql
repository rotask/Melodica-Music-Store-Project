use master
go

IF DB_ID('MelodicaStaging') IS NOT NULL begin
	alter database MelodicaStaging set single_user with rollback immediate
	drop database MelodicaStaging;
end
go

IF DB_ID('MelodicaDW') IS NOT NULL begin
	alter database MelodicaDW set single_user with rollback immediate
	drop database MelodicaDW;
end
go 