create database Campeonato
go
use Campeonato
GO

-- ###### Criando as tabelas ###### --
create table [Time] (
    Nome varchar(130) not null,
    Apelido varchar(130) not null,
    DataCriacao varchar(10),

    constraint PK_Time primary key (Nome),
)
go

create table Partida (
    IDJogo int not null,
    Casa varchar(130) not null,
    Visitante varchar(130) not null,
    GolsCasa int not null,
    GolsVisitante int not null,
    TotalGols int,
    Resultado varchar(130),

    constraint PK_Partida primary key (Casa, Visitante),
    constraint FK_Partida_Casa foreign key (casa) references [Time](Nome),
    constraint FK_Partida_Visitante foreign key (Visitante) references [Time](Nome),
    constraint UN_Jogo unique (IDJogo),
)
go

create table Pontos (
    NomeTime varchar(130) not null,
    Ponto int not null,
    GolsFeitos int not null,
    GolsSofridos int not null,
    MaiorNumeroDeGols int not null,

    constraint PK_Pontos primary key (NomeTime),
    constraint FK_Pontos_Time foreign key (NomeTime) references [Time] (Nome),
)
go

-- ###### Criando as Procedures ###### --

create or alter proc InsereTime @Nome varchar(130), @Apelido varchar(130), @DataCriacao varchar(10)
as
begin
    insert into [Time] (Nome, Apelido, DataCriacao) values (@Nome, @Apelido, @DataCriacao)
    print('Time criado com sucesso!')
end;
go

create or alter proc RealizaPartida @Jogo int, @Casa varchar(130), @Visitante varchar(130), @GolsCasa int, @GolsVisitante int
as
begin
    declare @Total int, @Resultado varchar(130)

    set @Total = @GolsCasa + @GolsVisitante

    if(@GolsCasa > @GolsVisitante)
        set @Resultado = @Casa
    else if (@GolsCasa < @GolsVisitante)
        set @Resultado = @Visitante
    else
        set @Resultado = 'Empate'

    insert into Partida (IDJogo, Casa, Visitante, GolsCasa, GolsVisitante, TotalGols, Resultado) values (@Jogo, @Casa, @Visitante, @GolsCasa, @GolsVisitante, @Total, @Resultado)
end;
go

create or alter proc InserePontos @NomeTime varchar(130)
as
begin
    insert into Pontos (NomeTime, Ponto, GolsFeitos, GolsSofridos, MaiorNumeroDeGols) values (@NomeTime, 0, 0, 0, 0)
end;
go

create or alter proc MaiorNumeroDeGols @NomeTIme varchar(130), @GolsPartida int
as
begin
    declare @MaiorNumeroDeGols int

    select @MaiorNumeroDeGols = MaiorNumeroDeGols from Pontos where NomeTime = @NomeTIme

    if(@MaiorNumeroDeGols < @GolsPartida)
        update Pontos set MaiorNumeroDeGols = @GolsPartida where NomeTime = @NomeTIme 
end;
go

create or alter proc Campeao
as
begin
    select top 1 NomeTime, Ponto, (GolsFeitos - GolsSofridos) as SaldoDeGol from Pontos order by Ponto desc, SaldoDeGol desc
end;
go

create or alter proc ClassificacaoTopCinco
as
begin
    select top 5 NomeTime, Ponto, (GolsFeitos - GolsSofridos) as SaldoDeGol from Pontos order by Ponto desc, SaldoDeGol desc
end;
go

create or alter proc MaiorNumeroDeGolsFeitos
as
begin
    select top 1 NomeTIme, GolsFeitos from Pontos order by GolsFeitos desc
end;
go

create or alter proc MaiorNumeroDeGolsSofridos
as
begin
    select top 1 NomeTIme, GolsSofridos from Pontos order by GolsSofridos desc
end;
go

create or alter proc PartidaComMaisGols
as
begin
    select top 1 Casa, Visitante, TotalGols from Partida order by TotalGols desc
end;
go

create or alter proc MaiorNumeroDeGolsPartida
as
begin
    select NomeTime, MaiorNumeroDeGols from Pontos order by MaiorNumeroDeGols desc
end;
go

-- ###### Criando as Triggers ###### --

create or alter trigger TGR_Pontos on Partida after insert
as
begin
    declare @Casa varchar(130), @Visitante varchar(130), @GolsCasa int, @GolsVisitante int, @Resultado varchar(130)

    select @Casa = Casa, @Visitante = Visitante, @GolsCasa = GolsCasa, @GolsVisitante = GolsVisitante, @Resultado = Resultado from inserted

    EXEC.MaiorNumeroDeGols @Casa, @GolsCasa
    EXEC.MaiorNumeroDeGols @Visitante, @GolsVisitante

    if(@Resultado = 'Empate')
    begin
        update Pontos set Ponto += 1, GolsFeitos = GolsFeitos + @GolsCasa, GolsSofridos = GolsSofridos + @GolsVisitante where NomeTime = @Casa
        update Pontos set Ponto += 1, GolsFeitos = GolsFeitos + @GolsVisitante, GolsSofridos = GolsSofridos + @GolsCasa where NomeTime = @Visitante
    end
    else if(@Resultado = @Casa)
    begin
        update Pontos set Ponto += 3, GolsFeitos = GolsFeitos + @GolsCasa, GolsSofridos = GolsSofridos + @GolsVisitante where NomeTime = @Casa
        update Pontos set GolsFeitos = GolsFeitos + @GolsVisitante, GolsSofridos = GolsSofridos + @GolsCasa where NomeTime = @Visitante
    end
    else if(@Resultado = @Visitante)
    begin
        update Pontos set GolsFeitos += @GolsCasa, GolsSofridos += @GolsVisitante where NomeTime = @Casa
        update Pontos set Ponto += 5, GolsFeitos += @GolsVisitante, GolsSofridos += @GolsCasa where NomeTime = @Visitante
    end
end;
go

EXEC.InsereTime 'Toma Mobile', 'Mobilezin', '20/02/2015'
EXEC.InsereTime 'Papa Entulhos', 'PPE', '06/08//2014'
EXEC.InsereTime 'Vulgo Uma Tonelada', 'VUT', '17/05/2020'
EXEC.InsereTime 'VUCK VUCK FANS', 'VVF', '06/07/2022'
EXEC.InsereTime 'Reis Do Capa 3', 'RC3', '19/11/2023'

select * from [Time]

EXEC.InserePontos 'Toma Mobile'
EXEC.InserePontos 'Papa Entulhos'
EXEC.InserePontos 'Vulgo Uma Tonelada'
EXEC.InserePontos 'VUCK VUCK FANS'
EXEC.InserePontos 'Reis Do Capa 3'

select * from Pontos

EXEC.RealizaPartida 1, 'Toma Mobile', 'Papa Entulhos', 2, 5
EXEC.RealizaPartida 2, 'Toma Mobile', 'Vulgo Uma Tonelada', 1, 8
EXEC.RealizaPartida 3, 'Toma Mobile', 'VUCK VUCK FANS', 0, 10
EXEC.RealizaPartida 4, 'Toma Mobile', 'Reis Do Capa 3', 7, 3

EXEC.RealizaPartida 5, 'Papa Entulhos', 'Toma Mobile', 3, 9
EXEC.RealizaPartida 6, 'Papa Entulhos', 'Vulgo Uma Tonelada', 5, 0
EXEC.RealizaPartida 7, 'Papa Entulhos', 'VUCK VUCK FANS', 6, 10
EXEC.RealizaPartida 8, 'Papa Entulhos', 'Reis Do Capa 3', 7, 8

EXEC.RealizaPartida 9, 'Vulgo Uma Tonelada', 'Toma Mobile', 9, 3
EXEC.RealizaPartida 10, 'Vulgo Uma Tonelada', 'Papa Entulhos', 4, 0
EXEC.RealizaPartida 11, 'Vulgo Uma Tonelada', 'VUCK VUCK FANS', 2, 10
EXEC.RealizaPartida 12, 'Vulgo Uma Tonelada', 'Reis Do Capa 3', 5, 7

EXEC.RealizaPartida 13, 'VUCK VUCK FANS', 'Toma Mobile', 5, 7
EXEC.RealizaPartida 14, 'VUCK VUCK FANS', 'Papa Entulhos', 0, 10
EXEC.RealizaPartida 15, 'VUCK VUCK FANS', 'Vulgo Uma Tonelada', 9, 2
EXEC.RealizaPartida 16, 'VUCK VUCK FANS', 'Reis Do Capa 3', 1, 3

EXEC.RealizaPartida 17, 'Reis Do Capa 3', 'Toma Mobile', 7, 1
EXEC.RealizaPartida 18, 'Reis Do Capa 3', 'Papa Entulhos', 9, 10
EXEC.RealizaPartida 19, 'Reis Do Capa 3', 'Vulgo Uma Tonelada', 8, 4
EXEC.RealizaPartida 20, 'Reis Do Capa 3', 'VUCK VUCK FANS', 0, 3

select * from partida

EXEC.Campeao
EXEC.ClassificacaoTopCinco
EXEC.MaiorNumeroDeGolsFeitos
EXEC.MaiorNumeroDeGolsSofridos
EXEC.PartidaComMaisGols
EXEC.MaiorNumeroDeGolsPartida