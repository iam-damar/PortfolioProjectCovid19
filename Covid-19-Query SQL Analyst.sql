
-- **

-- SQL Query for Tableau Covid-19 Project

-- **

-- SQL Untuk divisualisasikan ke Tableau

-- --------------------------------------------------------------------------------------------------------------
-- Query untuk Visualisasi


-- 1.
-- Melihat total terinfeksi dan kematian
use PortfolioProject;

select SUM(new_cases) as Total_terinfeksi_baru_per_hari, SUM(CAST(new_deaths as int)) as Total_Kematian_baru_per_hari, (SUM(CAST(new_deaths as int)) / SUM(new_cases))*100 as Persentase_kematian_baru_perhari
from PortfolioProject..CovidDeaths 
where continent is not null  
and location not in ('Upper middle income' ,'High income' ,'Lower middle income', 'Low income')
order by 1,2;

-- 2. 
-- Kita ingin melihat total kematian diseluruh dunia tanpa menyertakan location 'World', 'European Union', 'International',Etc.

Select location, SUM(cast(new_deaths as int)) as JumlahTotalKematian
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income' ,'High income' ,'Lower middle income', 'Low income')
Group by location
order by JumlahTotalKematian desc;

-- 3.
-- Lokasi negara dengan jumlah dan tingkat persentase terinfeksi covid-19 paling tinggi.

Select Location, Population, MAX(total_cases) as JumlahTingkatTerinfeksiTertinggi,  Max((total_cases/population))*100 as PersentasePopulasiTerinfeksi
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where location not in ('Upper middle income' ,'High income' ,'Lower middle income', 'Low income')
Group by Location, Population
order by PersentasePopulasiTerinfeksi desc;


-- 4.
-- Lokasi negara dengan jumlah dan tingkat persentase terinfeksi covid-19 paling tinggi berdasarkan tanggal.

Select Location, Population,date, MAX(total_cases) as JumlahTingkatTerinfeksiTertinggi,  ROUND(Max((total_cases/population))*100,2) as PersentasePopulasiTerinfeksi
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where location not in ('Upper middle income' ,'High income' ,'Lower middle income', 'Low income')
Group by Location, Population, date
order by PersentasePopulasiTerinfeksi desc;




-- --------------------------------------------------------------------------------------------
-- Query Lain hasil eksplorasi,

-- 1.
-- Join table
-- Melihat Total populasi yang sudah divaksinasi

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3;


-- 2.
-- Total keseluruhan Kasus terinfeksi covid-19 dan kematian antar benua beserta persentasenya.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2;

-- 3.
-- Total kasus terinfeksi dan kematian disetiap negara yang ada didunia.

Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 4.
-- Menggunakan CTE untuk melakukan Perhitungan persentase warga negara yang sudah vaksin pada query sebelumnya

With Populasi_Sudah_Vaksin (Continent, Location, Date, Population, New_Vaccinations, Warga_negara_telah_vaksinasi)
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(REPLACE(CAST(vac.new_vaccinations as nvarchar),'.0','') as BIGINT)) OVER 
 (Partition by dea.Location Order by dea.location, dea.date) as Warga_negara_telah_vaksinasi
-- Bisa menggunakan query komentar dibawah ini untuk melihat persentase total warga negara dimasing2 negara yang sudah divaksinasi
--, (Warga_negara_telah_vaksinasi/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *,ROUND((Warga_negara_telah_vaksinasi/Population)*100,2) as Persentase_Populasi_sudah_vaksin from Populasi_Sudah_Vaksin;


-- 5.
-- Melihat Negara dengan total terinfeksi covid tertinggi dari populasi keseluruhan manusia yang ada dinegara tersebut.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc;



-- Membuat Temporary Table

--DROP TABLE if exists Persentase_populasi_telah_vaksin;

--create table Persentase_populasi_telah_vaksin(

--	Continent nvarchar(255),
--	Location nvarchar(255),
--	Date datetime,
--	Population numeric,
--	New_Vaccinations numeric,
--	Warga_negara_telah_vaksinasi numeric,

--)

--insert into Persentase_populasi_telah_vaksin
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CAST(REPLACE(CAST(vac.new_vaccinations as nvarchar),'.0','') as BIGINT)) OVER 
-- (Partition by dea.Location Order by dea.location, dea.date) as Warga_negara_telah_vaksinasi
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--select *,(Warga_negara_telah_vaksinasi/Population)*100 from Persentase_populasi_telah_vaksin;


---- Membuat View

--create view View_Persentase_populasi_telah_vaksin as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CAST(REPLACE(CAST(vac.new_vaccinations as nvarchar),'.0','') as BIGINT)) OVER 
-- (Partition by dea.Location Order by dea.location, dea.date) as Warga_negara_telah_vaksinasi
---- Bisa menggunakan query komentar dibawah ini untuk melihat persentase total warga negara dimasing2 negara yang sudah divaksinasi
----, (Warga_negara_telah_vaksinasi/dea.population)*100
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null


--Select * from View_Persentase_populasi_telah_vaksin;
