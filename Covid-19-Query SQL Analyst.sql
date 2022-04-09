
select * from PortfolioProject..CovidDeaths where continent is not null order by 3,4;
--select * from PortfolioProject..CovidVaccinations order by 3,4;

-- Menset Data yang akan digunakan.
select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths where continent is not null order by 1,2;

-- Melihat persentase Kematian diseluruh dunia berdasarkan total orang2 yang terinfeksi
select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as Persentase_Kematian 
from PortfolioProject..CovidDeaths where continent is not null order by 1,2;

-- Melihat Persentase kematian di negara Indonesia berdasarkan total orang2 yang terinfeksi
-- Total Kasus terinfeksi dan kematian akibat Covid-19 di Indonesia meningkat setiap tahun dari february 2020 - april 2022
-- Persentase kasus terinfeksi terhadap kasus kematian diIndonesia rata rata 2-8 % dari seluruh negara yang ada diDunia.
select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as Persentase_Kematian 
from PortfolioProject..CovidDeaths 
where location LIKE '%Indonesia'
and continent is not null 
order by 1,2;

-- Melihat persentase orang-orang yang terinfeksi dimasing2 negara diseluruh dunia berdasakan jumlah populasi manusianya.
select location, date, total_cases, population, ROUND((total_cases/population)*100,2) as Persentase_terjangkit_COVID 
from PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2;

-- Melihat persentase total orang yang terinfeksi COVID-19 di Indonesia berdasarkan jumlah populasi manusianya.
select location, date, total_cases, population, ROUND((total_cases/population)*100,2) as Persentase_terjangkit_COVID 
from PortfolioProject..CovidDeaths 
where location LIKE '%Indonesia'
and continent is not null 
order by 1,2;

-- Melihat Negara didunia dengan tingkat infeksi terbanyak berdasarkan jumlah populasi manusianya.
select location, population, MAX(total_cases) as JumlahInfeksiTertinggi, ROUND(MAX((total_cases/population))*100,2) as Persentase_terjangkit_COVID 
from PortfolioProject..CovidDeaths 
where continent is not null 
group by location, population
order by Persentase_terjangkit_COVID DESC;

-- Melihat negara didunia dengan tingkat kematian terbanyak berdasarkan jumlah populasi manusianya.
select location, MAX(cast(total_deaths as int)) as JumlahKematian
from PortfolioProject..CovidDeaths 
where continent is not null 
group by location
order by JumlahKematian DESC;

-- 
-- Melihat tingkat kematian terbanyak antar benua didunia.
select continent, MAX(cast(total_deaths as int)) as JumlahKematian
from PortfolioProject..CovidDeaths 
where continent is not null 
group by continent
order by JumlahKematian DESC;

-- Melihat total terinfeksi dan kematian berdasarkan tanggal/date per harinya
select date, SUM(new_cases) as Total_terinfeksi_baru_per_hari, SUM(CAST(new_deaths as int)) as Total_Kematian_baru_per_hari, ROUND((SUM(CAST(new_deaths as int)) / SUM(new_cases))*100,2) as Persentase_kematian_baru_perhari
from PortfolioProject..CovidDeaths 
where continent is not null 
group by date
order by 1,2;


-- Join table
-- Melihat Total populasi yang sudah divaksinasi

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(REPLACE(CAST(vac.new_vaccinations as nvarchar),'.0','') as BIGINT)) OVER 
 (Partition by dea.Location Order by dea.location, dea.date) as Warga_negara_telah_vaksinasi
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


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
select *,ROUND((Warga_negara_telah_vaksinasi/Population)*100,2) from Populasi_Sudah_Vaksin;


-- Membuat Temporary Table

DROP TABLE if exists Persentase_populasi_telah_vaksin;

create table Persentase_populasi_telah_vaksin(

	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	Warga_negara_telah_vaksinasi numeric,

)

insert into Persentase_populasi_telah_vaksin
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(REPLACE(CAST(vac.new_vaccinations as nvarchar),'.0','') as BIGINT)) OVER 
 (Partition by dea.Location Order by dea.location, dea.date) as Warga_negara_telah_vaksinasi
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
select *,(Warga_negara_telah_vaksinasi/Population)*100 from Persentase_populasi_telah_vaksin;


-- Membuat View

create view View_Persentase_populasi_telah_vaksin as
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


Select * from View_Persentase_populasi_telah_vaksin;