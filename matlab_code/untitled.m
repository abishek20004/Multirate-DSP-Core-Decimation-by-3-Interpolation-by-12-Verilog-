clc;
clear;
close all;

%% ============================================================
%  PROJECT PARAMETERS
% ============================================================

Fs_in  = 120e6;          % Input sampling frequency
Fs_dec = Fs_in / 3;      % Decimation by 3 -> 40 MHz
Fs_int = Fs_dec * 12;    % Interpolation by 12 -> 480 MHz

Fsignal = 1e6;           % Input sine-wave frequency


%% ============================================================
%  FILE PATHS
% ============================================================

input_file = ...
    'C:\Vivado_projects\project_2\input_sine_q15.txt';

dec_file = ...
    'C:\Vivado_projects\project_2\decimated_output.txt';

interp_file = ...
    'C:\Vivado_projects\project_2\interpolated_output.txt';


%% ============================================================
%  READ INPUT SIGNAL
% ============================================================

input_q15 = readmatrix(input_file);

% Make sure it is a column vector
input_q15 = input_q15(:);

% Q1.15 integer -> floating point
input_signal = input_q15 / 2^15;


%% ============================================================
%  READ DECIMATED OUTPUT
% ============================================================

dec_q15 = readmatrix(dec_file);

% Make sure it is a column vector
dec_q15 = dec_q15(:);

% Q1.15 integer -> floating point
dec_signal = dec_q15 / 2^15;


%% ============================================================
%  READ INTERPOLATED OUTPUT
%
%  The interpolator produces 4 parallel 16-bit samples.
%  Therefore each row contains:
%
%  sample0 sample1 sample2 sample3
%
%  Convert the matrix into one continuous sample stream.
% ============================================================

interp_data = readmatrix(interp_file);

% Transpose first so samples are read in row order
interp_q15 = interp_data.';

% Convert matrix to one continuous column
interp_q15 = interp_q15(:);

% Q1.15 integer -> floating point
interp_signal = interp_q15 / 2^15;


%% ============================================================
%  DISPLAY BASIC INFORMATION
% ============================================================

fprintf('\n');
fprintf('===============================================\n');
fprintf('PROJECT SIGNAL INFORMATION\n');
fprintf('===============================================\n');

fprintf('Input samples        : %d\n', length(input_signal));
fprintf('Decimated samples    : %d\n', length(dec_signal));
fprintf('Interpolated samples : %d\n', length(interp_signal));

fprintf('\n');

fprintf('Input Fs              : %.2f MHz\n', Fs_in/1e6);
fprintf('Decimated Fs          : %.2f MHz\n', Fs_dec/1e6);
fprintf('Interpolated Fs       : %.2f MHz\n', Fs_int/1e6);

fprintf('\n');

fprintf('Input duration        : %.3f us\n', ...
    length(input_signal)/Fs_in*1e6);

fprintf('Decimated duration    : %.3f us\n', ...
    length(dec_signal)/Fs_dec*1e6);

fprintf('Interpolated duration : %.3f us\n', ...
    length(interp_signal)/Fs_int*1e6);

fprintf('===============================================\n');


%% ============================================================
%  FFT - INPUT
% ============================================================

N_in = length(input_signal);

Y_in = fft(input_signal);

% Normalize FFT
P2_in = abs(Y_in / N_in);

% Single-sided spectrum
P1_in = P2_in(1:floor(N_in/2)+1);

P1_in(2:end-1) = 2 * P1_in(2:end-1);

% Convert to dB
P1_in_dB = 20 * log10(P1_in + eps);

% Frequency axis
f_in = Fs_in * (0:floor(N_in/2)) / N_in;


%% ============================================================
%  FFT - DECIMATED OUTPUT
% ============================================================

N_dec = length(dec_signal);

Y_dec = fft(dec_signal);

% Normalize FFT
P2_dec = abs(Y_dec / N_dec);

% Single-sided spectrum
P1_dec = P2_dec(1:floor(N_dec/2)+1);

P1_dec(2:end-1) = 2 * P1_dec(2:end-1);

% Convert to dB
P1_dec_dB = 20 * log10(P1_dec + eps);

% Frequency axis
f_dec = Fs_dec * (0:floor(N_dec/2)) / N_dec;


%% ============================================================
%  FFT - INTERPOLATED OUTPUT
% ============================================================

N_int = length(interp_signal);

Y_int = fft(interp_signal);

% Normalize FFT
P2_int = abs(Y_int / N_int);

% Single-sided spectrum
P1_int = P2_int(1:floor(N_int/2)+1);

P1_int(2:end-1) = 2 * P1_int(2:end-1);

% Convert to dB
P1_int_dB = 20 * log10(P1_int + eps);

% Frequency axis
f_int = Fs_int * (0:floor(N_int/2)) / N_int;


%% ============================================================
%  FIND PEAK FREQUENCY
% ============================================================

[peak_in, idx_in] = max(P1_in);
freq_peak_in = f_in(idx_in);

[peak_dec, idx_dec] = max(P1_dec);
freq_peak_dec = f_dec(idx_dec);

[peak_int, idx_int] = max(P1_int);
freq_peak_int = f_int(idx_int);


%% ============================================================
%  PRINT FFT RESULTS
% ============================================================

fprintf('\n');
fprintf('===============================================\n');
fprintf('FFT RESULTS\n');
fprintf('===============================================\n');

fprintf('Input FFT:\n');
fprintf('  Sampling frequency = %.2f MHz\n', Fs_in/1e6);
fprintf('  Peak frequency     = %.6f MHz\n', ...
    freq_peak_in/1e6);
fprintf('  Peak magnitude     = %.2f dB\n', ...
    20*log10(peak_in + eps));

fprintf('\n');

fprintf('Decimated FFT:\n');
fprintf('  Sampling frequency = %.2f MHz\n', Fs_dec/1e6);
fprintf('  Peak frequency     = %.6f MHz\n', ...
    freq_peak_dec/1e6);
fprintf('  Peak magnitude     = %.2f dB\n', ...
    20*log10(peak_dec + eps));

fprintf('\n');

fprintf('Interpolated FFT:\n');
fprintf('  Sampling frequency = %.2f MHz\n', Fs_int/1e6);
fprintf('  Peak frequency     = %.6f MHz\n', ...
    freq_peak_int/1e6);
fprintf('  Peak magnitude     = %.2f dB\n', ...
    20*log10(peak_int + eps));

fprintf('===============================================\n');


%% ============================================================
%  FULL-BAND FFT - INPUT
% ============================================================

figure;

plot(f_in/1e6, P1_in_dB, 'LineWidth', 1.2);

grid on;

xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

title('FFT of Input Signal');

xlim([0 Fs_in/2/1e6]);

ylim([-120 5]);


%% ============================================================
%  FULL-BAND FFT - DECIMATED OUTPUT
% ============================================================

figure;

plot(f_dec/1e6, P1_dec_dB, 'LineWidth', 1.2);

grid on;

xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

title('FFT of Decimated Output');

xlim([0 Fs_dec/2/1e6]);

ylim([-120 5]);


%% ============================================================
%  FULL-BAND FFT - INTERPOLATED OUTPUT
% ============================================================

figure;

plot(f_int/1e6, P1_int_dB, 'LineWidth', 1.2);

grid on;

xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

title('FFT of Interpolated Output');

xlim([0 Fs_int/2/1e6]);

ylim([-180 5]);


%% ============================================================
%  ZOOMED FFT - INPUT
% ============================================================

figure;

plot(f_in/1e6, P1_in_dB, 'LineWidth', 1.2);

grid on;

xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

title('Input Signal FFT - 1 MHz Region');

xlim([0 5]);

ylim([-120 5]);


%% ============================================================
%  ZOOMED FFT - DECIMATED
% ============================================================

figure;

plot(f_dec/1e6, P1_dec_dB, 'LineWidth', 1.2);

grid on;

xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

title('Decimated Output FFT - 1 MHz Region');

xlim([0 5]);

ylim([-120 5]);


%% ============================================================
%  ZOOMED FFT - INTERPOLATED
% ============================================================

figure;

plot(f_int/1e6, P1_int_dB, 'LineWidth', 1.2);

grid on;

xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

title('Interpolated Output FFT - 1 MHz Region');

xlim([0 5]);

ylim([-180 5]);


%% ============================================================
%  MARK 1 MHz ON ZOOMED PLOTS
% ============================================================

figure;

plot(f_in/1e6, P1_in_dB, 'LineWidth', 1.2);

grid on;
hold on;

xline(1, '--');

xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

title('Input FFT with 1 MHz Signal');

xlim([0 5]);
ylim([-120 5]);


figure;

plot(f_dec/1e6, P1_dec_dB, 'LineWidth', 1.2);

grid on;
hold on;

xline(1, '--');

xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

title('Decimated Output FFT with 1 MHz Signal');

xlim([0 5]);
ylim([-120 5]);


figure;

plot(f_int/1e6, P1_int_dB, 'LineWidth', 1.2);

grid on;
hold on;

xline(1, '--');

xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

title('Interpolated Output FFT with 1 MHz Signal');

xlim([0 5]);
ylim([-180 5]);

%% ============================================================
% SAVE ALL 9 MATLAB FIGURES
% ============================================================

save_folder = 'C:\Vivado_projects\project_2\MATLAB_Plots';

if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

figures = findall(0, 'Type', 'figure');

% Sort figures by figure number
figures = sort(figures);

for k = 1:length(figures)

    filename = fullfile(save_folder, ...
        sprintf('Figure_%02d.png', k));

    exportgraphics(figures(k), filename, ...
        'Resolution', 300);

end

fprintf('\n========================================\n');
fprintf('ALL MATLAB FIGURES SAVED\n');
fprintf('========================================\n');
fprintf('Number of figures saved: %d\n', length(figures));
fprintf('Folder:\n%s\n', save_folder);
fprintf('========================================\n');