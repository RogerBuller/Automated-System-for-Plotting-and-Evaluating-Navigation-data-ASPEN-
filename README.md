# ASPEN Flight Data Processing and Visualization

ASPEN is a MATLAB-based rocket flight telemetry processing and visualization suite designed for high-power and experimental amateur rocketry applications.

The software loads high-rate and low-rate flight telemetry, synchronizes the datasets into a unified timetable, performs altitude and velocity state estimation, generates plots, animates the rocket trajectory in 3D using quaternion attitude data, and exports processed flight results.

The current implementation is optimized for:
- High-power amateur rockets
- Student rocketry teams
- Flight dynamics visualization

---

# Features

## Telemetry Synchronization

- Loads separate high-rate and low-rate CSV telemetry files
- Synchronizes telemetry streams into a unified MATLAB timetable
- Automatically fills missing samples using nearest-neighbor interpolation

## Flight State Estimation

- Barometric altitude filtering
- Accelerometer-assisted velocity prediction
- Complementary/Kalman-style altitude fusion
- Barometric outlier rejection
- Accelerometer bias removal

## Visualization

- 2D telemetry plotting
- Quaternion-driven 3D rocket animation
- Downrange and crossrange trajectory reconstruction

## Export System

Exports:
- Filtered altitude
- Filtered velocity
- Filtered acceleration
- Full fused datasets
- Figures as PNG
- MATLAB FIG files

---

# File Structure

Main Script:
- ASPEN.m

Required Functions:
- kalman_altitude_fusion_6dof.m
- animate_rocket_3d_quat.m
- plot_selected_data.m
- quat_to_rotm.m

---

# Current Filter Design

The altitude estimator is a lightweight complementary/Kalman-style fusion filter using:
- Barometric altitude
- Longitudinal acceleration
- Velocity prediction
- Residual-based correction

The design prioritizes:
- Numerical stability
- Simplicity

---

# Future Improvements

Planned improvements may include:
- GPS fusion
- Wind estimation
- Mach compensation
- Multi-stage support
- Recovery event detection
- Monte Carlo trajectory reconstruction

---

# Usage

1. Run ASPEN.m
2. Select project directory
3. Load HR and LR CSV files
4. Select plotting variables
5. Review generated plots and animation
6. Export processed data and figures
