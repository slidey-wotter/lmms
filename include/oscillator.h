/*
 * oscillator.h - header-file for oscillator.cpp, a powerful oscillator-class
 *
 * Copyright (c) 2004-2006 Tobias Doerffel <tobydox/at/users.sourceforge.net>
 * 
 * This file is part of Linux MultiMedia Studio - http://lmms.sourceforge.net
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program (see COPYING); if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 */


#ifndef _OSCILLATOR_H
#define _OSCILLATOR_H

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif

#include "mixer.h"
#include "sample_buffer.h"
#include "lmms_constants.h"
#include "lmms_math.h"


class oscillator
{
public:
	enum waveShapes
	{
		SIN_WAVE,
		TRIANGLE_WAVE,
		SAW_WAVE,
		SQUARE_WAVE,
		MOOG_SAW_WAVE,
		EXP_WAVE,
		WHITE_NOISE_WAVE,
		USER_DEF_WAVE
	} ;

	enum modulationAlgos
	{
		PHASE_MODULATION, AMP_MODULATION, MIX, SYNC, FREQ_MODULATION
	} ;

	oscillator( const waveShapes * _wave_shape,
			const modulationAlgos * _modulation_algo,
			const float * _freq,
			const float * _detuning,
			const float * _phase_offset,
			const float * _volume,
			oscillator * _m_subOsc = NULL ) FASTCALL;
	virtual ~oscillator()
	{
		delete m_subOsc;
	}

	inline void setUserWave( sampleBuffer * _wave )
	{
		m_userWave = _wave;
	}

	void update( sampleFrame * _ab, const fpab_t _frames,
							const ch_cnt_t _chnl );

/*#define	FLOAT_TO_INT(in,out)		\
	register const float round_const = -0.5f;			\
	__asm__ __volatile__ ("fadd %%st,%%st(0)\n"		\
				"fadd	%2\n"			\
				"fistpl	%0\n"			\
				"shrl	$1,%0" : "=m" (out) : "t" (in),"m"(round_const) : "st") ;*/

	// now follow the wave-shape-routines...

	static inline sample_t sinSample( const float _sample )
	{
		return( sinf( _sample * F_2PI ) );
	}

	static inline sample_t triangleSample( const float _sample )
	{
		const float ph = fraction( _sample );
		if( ph <= 0.25f )
		{
			return( ph * 4.0f );
		}
		else if( ph <= 0.75f )
		{
			return( 2.0f - ph * 4.0f );
		}
		return( ph * 4.0f - 4.0f );
	}

	static inline sample_t sawSample( const float _sample )
	{
		return( -1.0f + fraction( _sample ) * 2.0f );
	}

	static inline sample_t squareSample( const float _sample )
	{
		return( ( fraction( _sample ) > 0.5f ) ? -1.0f : 1.0f );
	}

	static inline sample_t moogSawSample( const float _sample )
	{
		const float ph = fraction( _sample );
		if( ph < 0.5f )
		{
			return( -1.0f + ph * 4.0f );
		}
		return( 1.0f - 2.0f * ph );
	}

	static inline sample_t expSample( const float _sample )
	{
		float ph = fraction( _sample );
		if( ph > 0.5f )
		{
			ph = 1.0f - ph;
		}
		return( -1.0f + 8.0f * ph * ph );
	}

	static inline sample_t noiseSample( const float )
	{
		return( 1.0f - 2.0f * ( ( float )rand() * ( 1.0f /
								RAND_MAX ) ) );
	}

	inline sample_t userWaveSample( const float _sample )
	{
		if( m_userWave->frames() > 0 )
		{
			return( m_userWave->userWaveSample( _sample ) );
		}
		else
		{
			return( 0.0f );
		}
	}


private:
	const waveShapes * m_waveShape;
	const modulationAlgos * m_modulationAlgo;
	const float * m_freq;
	const float * m_detuning;
	const float * m_volume;
	const float * m_ext_phaseOffset;
	oscillator * m_subOsc;
	float m_phaseOffset;
	float m_phase;
	sampleBuffer * m_userWave;


	void updateNoSub( sampleFrame * _ab, const fpab_t _frames,
							const ch_cnt_t _chnl );
	void updatePM( sampleFrame * _ab, const fpab_t _frames,
							const ch_cnt_t _chnl );
	void updateAM( sampleFrame * _ab, const fpab_t _frames,
							const ch_cnt_t _chnl );
	void updateMix( sampleFrame * _ab, const fpab_t _frames,
							const ch_cnt_t _chnl );
	void updateSync( sampleFrame * _ab, const fpab_t _frames,
							const ch_cnt_t _chnl );
	void updateFM( sampleFrame * _ab, const fpab_t _frames,
							const ch_cnt_t _chnl );

	float syncInit( sampleFrame * _ab, const fpab_t _frames,
							const ch_cnt_t _chnl );
	inline bool syncOk( float _osc_coeff );

	inline sample_t getSample( const float _sample );
	inline void FASTCALL recalcPhase( void );

} ;


#endif
