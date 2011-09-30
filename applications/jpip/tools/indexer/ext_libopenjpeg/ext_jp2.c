/*
 * $Id$
 *
 * Copyright (c) 2002-2011, Communications and Remote Sensing Laboratory, Universite catholique de Louvain (UCL), Belgium
 * Copyright (c) 2002-2011, Professor Benoit Macq
 * Copyright (c) 2010-2011, Kaori Hagihara
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS `AS IS'
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>

#include "ext_openjpeg.h"
#include "cio.h"
#include "cio_ext.h"
#include "cidx_manager.h"
#include "indexbox_manager.h"

/* 
 * Write JP box
 *    copy from jp2.c
 *
 * @param[in] cio file output handler
 */
void jp2_write_jp(opj_cio_t *cio);

/* 
 * Write FTYP box - File type box
 *    copy from jp2.c
 *
 * @param[in] jp2 JP2 handle
 * @param[in] cio file output handle
 */
void jp2_write_ftyp(opj_jp2_t *jp2, opj_cio_t *cio);

/* 
 * Write file Index (superbox)
 *
 * @param[in] offset_jp2c offset of jp2c box
 * @param[in] length_jp2c length of jp2c box
 * @param[in] offset_idx  offset of cidx box
 * @param[in] length_idx  length of cidx box
 * @param[in] cio         file output handle
 * @return                length of fidx box
 */
int write_fidx( int offset_jp2c, int length_jp2c, int offset_idx, int length_idx, opj_cio_t *cio);

/* 
 * Write index Finder box
 *
 * @param[in] offset offset of fidx box
 * @param[in] length length of fidx box
 * @param[in] cio         file output handle
 */
void write_iptr( int offset, int length, opj_cio_t *cio);

opj_bool idxjp2_encode( opj_cinfo_t *cinfo, opj_cio_t *cio, unsigned char *j2kstream, int j2klen, opj_codestream_info_t cstr_info, opj_image_t *image)
{  
  opj_jp2_t *jp2;
  int pos_iptr, pos_cidx, pos_jp2c, end_pos, pos_fidx, len_fidx;
  int i;
  
  jp2 = cinfo->jp2_handle;

  /* JP2 encoding */
 
  /* JPEG 2000 Signature box */
  jp2_write_jp(cio);
  /* File Type box */
  jp2_write_ftyp(jp2, cio);
  /* JP2 Header box */
  jp2_write_jp2h(jp2, cio);
  
  pos_iptr = cio_tell( cio);
  cio_skip( cio, 24); /* IPTR further ! */
  
  pos_jp2c = cio_tell( cio);

  cio_write( cio, j2klen+8, 4); // L NOTICE: modify for the extended box
  cio_write( cio, JP2_JP2C, 4);  // JP2C

  for( i=0; i<j2klen; i++)
    cio_write( cio, j2kstream[i], 1);

  pos_cidx = cio_tell( cio);

  write_cidx( pos_jp2c+8, cio, image, cstr_info, j2klen);

  pos_fidx = cio_tell( cio);
  len_fidx = write_fidx( pos_jp2c, pos_cidx-pos_jp2c, pos_cidx, cio_tell(cio), cio);

  end_pos = cio_tell( cio);

  cio_seek( cio, pos_iptr);
  write_iptr( pos_fidx, len_fidx, cio);
  
  cio_seek( cio, end_pos);

  return OPJ_TRUE;
}

void jp2_write_jp( opj_cio_t *cio)
{
  opj_jp2_box_t box;

  box.init_pos = cio_tell(cio);
  cio_skip(cio, 4);
  cio_write(cio, JP2_JP, 4);		/* JP2 signature */
  cio_write(cio, 0x0d0a870a, 4);

  box.length = cio_tell(cio) - box.init_pos;
  cio_seek(cio, box.init_pos);
  cio_write(cio, box.length, 4);	/* L */
  cio_seek(cio, box.init_pos + box.length);
}

void jp2_write_ftyp(opj_jp2_t *jp2, opj_cio_t *cio)
{
  unsigned int i;
  opj_jp2_box_t box;

  box.init_pos = cio_tell(cio);
  cio_skip(cio, 4);
  cio_write(cio, JP2_FTYP, 4);		/* FTYP */

  cio_write(cio, jp2->brand, 4);		/* BR */
  cio_write(cio, jp2->minversion, 4);	/* MinV */

  for (i = 0; i < jp2->numcl; i++) {
    cio_write(cio, jp2->cl[i], 4);	/* CL */
  }

  box.length = cio_tell(cio) - box.init_pos;
  cio_seek(cio, box.init_pos);
  cio_write(cio, box.length, 4);	/* L */
  cio_seek(cio, box.init_pos + box.length);
}


/* 
 * Write proxy box
 *
 * @param[in] offset_jp2c offset of jp2c box
 * @param[in] length_jp2c length of jp2c box
 * @param[in] offset_idx  offset of cidx box
 * @param[in] length_idx  length of cidx box
 * @param[in] cio         file output handle
 */
void write_prxy( int offset_jp2c, int length_jp2c, int offset_idx, int length_idx, opj_cio_t *cio);

int write_fidx( int offset_jp2c, int length_jp2c, int offset_idx, int length_idx, opj_cio_t *cio)
{  
  int len, lenp;
  
  lenp = cio_tell( cio);
  cio_skip( cio, 4);              /* L [at the end] */
  cio_write( cio, JPIP_FIDX, 4);  /* IPTR           */
  
  write_prxy( offset_jp2c, length_jp2c, offset_idx, offset_jp2c, cio);

  len = cio_tell( cio)-lenp;
  cio_seek( cio, lenp);
  cio_write( cio, len, 4);        /* L              */
  cio_seek( cio, lenp+len);  

  return len;
}

void write_prxy( int offset_jp2c, int length_jp2c, int offset_idx, int length_idx, opj_cio_t *cio)
{
  int len, lenp;

  lenp = cio_tell( cio);
  cio_skip( cio, 4);              /* L [at the end] */
  cio_write( cio, JPIP_PRXY, 4);  /* IPTR           */
  
  cio_ext_write( cio, offset_jp2c, 8); /* OOFF           */
  cio_write( cio, length_jp2c, 4); /* OBH part 1     */
  cio_write( cio, JP2_JP2C, 4);        /* OBH part 2     */
  
  cio_write( cio, 1,1);           /* NI             */

  cio_ext_write( cio, offset_idx, 8);  /* IOFF           */
  cio_write( cio, length_idx, 4);  /* IBH part 1     */
  cio_write( cio, JPIP_CIDX, 4);   /* IBH part 2     */

  len = cio_tell( cio)-lenp;
  cio_seek( cio, lenp);
  cio_write( cio, len, 4);        /* L              */
  cio_seek( cio, lenp+len);
}

void write_iptr( int offset, int length, opj_cio_t *cio)
{
  int len, lenp;
  
  lenp = cio_tell( cio);
  cio_skip( cio, 4);              /* L [at the end] */
  cio_write( cio, JPIP_IPTR, 4);  /* IPTR           */
  
  cio_ext_write( cio, offset, 8);
  cio_ext_write( cio, length, 8);

  len = cio_tell( cio)-lenp;
  cio_seek( cio, lenp);
  cio_write( cio, len, 4);        /* L             */
  cio_seek( cio, lenp+len);
}
